module Patches
  class Rails < Base
    class << self
      def apply
        write_file("/etc/systemd/system/rails.service", rails_unit)
        write_file("/etc/systemd/system/sidekiq.service", sidekiq_unit)
        run_remote("sudo systemctl daemon-reload")

        File.open("#{local_dir}/config/sidekiq.yml", 'w') { |f| f << sidekiq_yml }
        write_file("#{remote_dir}/config/sidekiq.yml", sidekiq_yml)

        restart_service("rails", force: true)
        restart_service("sidekiq", force: true)
      end

      # ---

      def sidekiq_yml
        @sidekiq_yml ||= begin
          items = run_local('rails runner "puts ApplicationJob.descendants.map { |x| [x.name, x.schedule] }.to_h.to_json"')
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
          ExecStart=bash -c \"#{rails_prefix} sidekiq -c #{job_concurrency} | tee #{remote_dir}/log/sidekiq.log\"
          Restart=always

          [Install]
          WantedBy=default.target
        TEXT
      end
    end
  end
end
