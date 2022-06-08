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

      #
      # helpers
      #

      def installed?(program)
        Cmd.remote("command -v #{program}", bool: true)
      end

      def service_running?(service)
        Utils.nofail do
          stat = Cmd.remote("sudo systemctl | grep #{service}.service")&.downcase
          %w[loaded active running].all? { |x| stat.include?(x) }
        end
      end

      def restart_service(service, force: false)
        return if !force && service_running?(service)

        Cmd.remote("sudo systemctl enable #{service}.service")
        Cmd.remote("sudo systemctl restart #{service}.service")

        raise 'not running' unless service_running?(service)
      rescue StandardError => e
        sleep(5)
        raise 'not running' unless service_running?(service)
      end

      def files_same?(path, data)
        Utils.nofail do
          md5local = Digest::MD5.hexdigest(data + "\n")
          md5remote = Cmd.remote("sudo md5sum #{path}").split(' ').first

          return md5local == md5remote
        end
      end

      def text_same?(a, b)
        a.to_s.split("\n").select(&:present?) == b.to_s.split("\n").select(&:present?)
      end

      def write_file_local(path, data)
        Cmd.local("rm -f #{path}")
        File.open(path, 'w+') { |f| f << data; f << "\n" }
      end

      def with_tmp_file(data = "")
        path = File.expand_path(File.join(local_dir, 'tmp', SecureRandom.hex(16)))
        Cmd.local("touch #{path}")
        File.open(path, 'w+') { |f| f << data } if data.present?
        result = yield(path)
        Cmd.local("rm #{path}")
        result
      end

      def write_file(path, data)
        # do nothing if the files are the same
        return if files_same?(path, data)

        # create remote dir if it doesn't exist
        unless Cmd.remote("sudo [ -d #{File.dirname(path)} ]", bool: true)
          Utils.nofail { Cmd.remote("mkdir -p #{File.dirname(path)}") } || Cmd.remote("sudo mkdir -p #{File.dirname(path)}")
        end

        # setup tmp files for copy
        local_tmp_file = File.expand_path(File.join(local_dir, 'tmp', 'file_to_upload'))
        remote_tmp_file = '/tmp/uploaded_file'

        # copy over file
        write_file_local(local_tmp_file, data)
        Cmd.local("scp -i #{Secrets.id_rsa_path} #{local_tmp_file} #{Instance.username}@#{Instance.ipv4}:#{remote_tmp_file}")
        Cmd.remote("sudo cp #{remote_tmp_file} #{path}")
      end
    end
  end
end
