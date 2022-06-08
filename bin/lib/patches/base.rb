module Patches
  class Base
    class << self
      #
      # interface
      #

      def call
        start_time = Time.now
        puts "\n////// #{name.split('::').last.underscore.gsub('_', ' ').titleize} //////\n\n" if leaf?

        Instance.reload
        apply if needed?

        puts "\ntook #{(Time.now - start_time).round(2)}s" if leaf?
      end

      def leaf?
        true
      end

      def needed?
        true
      end

      def apply
        raise 'implement apply'
      end

      def pry
        binding.pry
      end

      #
      # "constants"
      #

      def local_dir
        File.dirname(File.dirname(File.dirname(__dir__)))
      end

      def remote_dir
        "/var/www/#{Utils.domain_name}"
      end

      def mounts
        x = {}
        x = { dbs: Secrets.dbs_bucket } if Secrets.dbs_bucket.present?
        x = Config.mounts.merge(x) if Config.mounts.present?
        x
      end

      def subdomains
        Array
          .wrap(Config.subdomains)
          .compact
          .push('www', 'gf', 'sq')
          .uniq
          .map { |x| "#{x}.#{Utils.domain_name}" }
          .unshift(Utils.domain_name)
      end

      def job_concurrency
        Config.job_concurrency || 3
      end

      def rclone_conf_path
        File.expand_path("~/.config/secrets/rclone.conf")
      end

      def remote_rclone_conf_path
        "/home/#{Instance.username}/.config/rclone/rclone.conf"
      end

      def asdf_prefix
        '. /opt/asdf-vm/asdf.sh; asdf'
      end

      def asdf_exec_prefix
        '. /opt/asdf-vm/asdf.sh; asdf exec'
      end

      def yay_prefix
        'yay --nodiffmenu --noeditmenu --nouseask --nocleanmenu --noupgrademenu --noconfirm'
      end

      def rails_prefix
        env = {
          rails_env: :production,
          rails_max_threads: 32,
          malloc_arena_max: 2,
          queue: '*',
        }.map { |k, v| "export #{k.to_s.upcase}=#{v}" }.join('; ')

        "cd #{remote_dir}; #{env}; #{asdf_exec_prefix} bundle exec"
      end

      def influx_token
        @influx_token ||= Cmd.remote('influx auth list --json | grep token')
          .then { |x| JSON.parse("{#{x.gsub(',', '')}}") }
          .dig('token')
      end

      def tool_versions
        [local_dir, remote_dir]
          .find { |x| Dir.exist?(x) }
          .then { |x| File.join(x, '.tool-versions') }
          .then { |x| File.readlines(x) }
          .map(&:split)
          .to_h
      end
    end
  end
end
