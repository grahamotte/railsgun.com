module Patches
  class Rails < Base
    class << self
      def apply
        Text.write_remote("/etc/systemd/system/rails.service", rails_unit)
        Text.write_remote("/etc/systemd/system/sidekiq.service", sidekiq_unit)
        Cmd.remote("sudo systemctl daemon-reload")

        File.open("#{Const.local_root}/config/sidekiq.yml", 'w') { |f| f << sidekiq_yml }
        Text.write_remote("#{Const.remote_root}/config/sidekiq.yml", sidekiq_yml)

        Instance.restart_service("rails", force: true)
        Instance.restart_service("sidekiq", force: true)
      end

      # ---

      def sidekiq_yml
        @sidekiq_yml ||= begin
          items = Cmd.local('rails runner "puts ApplicationJob.descendants.map { |x| [x.name, x.schedule] }.to_h.to_json"')
            .then { |x| JSON.parse(x) }
            .compact
            .map do |k, v|
              <<-TEXT
    #{k.underscore.gsub('/', '_')}:
      cron: '#{v} America/Los_Angeles'
      class: #{k}
              TEXT
            end

          <<-TEXT
production:
  :schedule:
#{items.join("\n")}

development:

          TEXT
        end
      end

      def rails_unit
        <<~TEXT
          [Unit]
          Description=Rails Server
          Wants=network-online-target
          After=network-online-target

          [Service]
          User=#{Instance.username}
          Type=simple
          ExecStart=bash -c "#{rails_prefix} rails server"
          Restart=always

          [Install]
          WantedBy=default.target
        TEXT
      end

      def sidekiq_unit
        <<~TEXT
          [Unit]
          Description=Sidekiq
          Wants=network-online-target
          After=network-online-target

          [Service]
          User=#{Instance.username}
          Type=simple
          ExecStart=bash -c \"#{rails_prefix} sidekiq -c #{job_concurrency} | tee #{Const.remote_root}/log/sidekiq.log\"
          Restart=always

          [Install]
          WantedBy=default.target
        TEXT
      end
    end
  end
end
