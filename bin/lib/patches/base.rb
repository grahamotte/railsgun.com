module Patches
  class Base
    class << self
      #
      # interface
      #

      def call
        @instance = nil
        pretty_name = name.split('::').last.underscore.gsub('_', ' ').titleize
        start_time = Time.now

        puts
        puts '#' * (pretty_name.length + 4)
        puts "# #{pretty_name} #"
        puts '#' * (pretty_name.length + 4)
        puts

        if always_needed?
          apply
        else
          should_run = false
          section("checking if needed") { should_run = needed? }
          section("applying patch") { apply } if should_run
        end

        puts
        puts "took #{(Time.now - start_time).round(2)}s"
      end

      def always_needed?
        false
      end

      def needed?
        raise 'implement needed'
      end

      def apply
        raise 'implement apply'
      end

      def pry
        binding.pry
      end

      #
      # variables
      #

      def remote_user
        Secrets.deployment_username
      end

      def remote_pass
        SecureRandom.hex(16)
      end

      def host
        File.basename(local_dir)
      end

      def project
        host.split('.').first
      end

      def ipv4
        instance.dig('ipv4').first
      end

      def local_dir
        File.dirname(File.dirname(File.dirname(__dir__)))
      end

      def remote_dir
        "/var/www/#{host}"
      end

      def mounts
        x = {}
        x = { dbs: Secrets.dbs_bucket } if Secrets.dbs_bucket.present?
        x = Config.mounts.merge(x) if Config.mounts.present?
        x
      end

      def rclone_conf_path
        File.expand_path("~/.config/secrets/rclone.conf")
      end

      def remote_rclone_conf_path
        "/home/#{remote_user}/config/rclone.conf"
      end

      #
      # helpers
      #

      def instance
        @instance ||= req(
          url: 'https://api.linode.com/v4/linode/instances',
          headers: { Authorization: "Bearer #{Secrets.linode_token}" },
        ).dig('data').find { |i| i.dig('label') == host }
      end

      def req(**params)
        params = { method: :get }.merge(params)

        puts "#{params.dig(:method).to_s.upcase} #{params.dig(:url)} #{params.dig(:payload)}".green

        RestClient::Request.execute(**params).body.then { |x| JSON.parse(x) }
      rescue StandardError => e
        pp e&.http_body
        raise e
      end

      def linode_req(**params)
        req(**params, headers: { Authorization: "Bearer #{Secrets.linode_token}", content_type: :json })
      end

      def run_remote(cmd, *opts, just_status: false)
        run(cmd, *opts, user: remote_user, host: ipv4, just_status: just_status)
      end

      def run_local(cmd, *opts, just_status: false)
        run(cmd, *opts, user: `whoami`.chomp, host: 'localhost', just_status: just_status)
      end

      def run(cmd, *opts, user:, host:, just_status: false)
        cmd = cmd % opts.map { |o| Shellwords.escape(o) } if opts.any?

        puts "RUN #{user}@#{host} #{cmd}".blue

        text = ""
        code = 0

        sleep(0.5)

        if host == 'localhost'
          Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
            loop { break unless (x = stdout.getc); print(x); text += x } # rubocop:disable Layout/EmptyLineAfterGuardClause
            loop { break unless (x = stderr.getc); print(x); text += x } # rubocop:disable Layout/EmptyLineAfterGuardClause
            code = wait_thr.value.to_i
          end
        else
          Net::SSH.start(host, user, keys: [Secrets.id_rsa_path]) do |s|
            s.open_channel do |channel|
              channel.exec(cmd) do
                channel.on_data { |_, data| print data; text += data }
                channel.on_extended_data { |_, _, data| print data; text += data }
                channel.on_request("exit-status") { |_, data| code = data.read_long }
              end
            end
            s.loop
          end
        end

        return code.zero? if just_status
        raise "error code #{code}" unless code.zero?

        text
      end

      def nofail
        yield
      rescue Net::SSH::ConnectionTimeout => e
        raise e
      rescue StandardError => e
        puts e.message
        false
      end

      def section(name)
        puts "*** #{name}..."
        yield if block_given?
        puts
      end

      def subsection(name)
        puts "--- #{name}..."
        yield if block_given?
        puts
      end

      def subdomains
        doms = %w[www gf sq]
        doms += Config.subdomains if Config.subdomains
        doms.map { |x| "#{x}.#{host}" }.unshift(host)
      end

      def asdf_prefix
        '. /opt/asdf-vm/asdf.sh; asdf'
      end

      def asdf_exec
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

        "cd #{remote_dir}; #{env}; #{asdf_exec} bundle exec"
      end

      def influx_token
        @influx_token ||= run_remote('influx auth list --json | grep token')
          .then { |x| JSON.parse("{#{x.gsub(',', '')}}") }
          .dig('token')
      end

      def installed?(program)
        run_remote("command -v #{program}", just_status: true)
      end

      def tool_versions
        [local_dir, remote_dir]
          .find { |x| Dir.exist?(x) }
          .then { |x| File.join(x, '.tool-versions') }
          .then { |x| File.readlines(x) }
          .map(&:split)
          .to_h
      end

      def service_running?(service)
        nofail do
          stat = run_remote("sudo systemctl | grep #{service}.service")&.downcase
          %w[loaded active running].all? { |x| stat.include?(x) }
        end
      end

      def restart_service(service, force: false)
        return if !force && service_running?(service)

        run_remote("sudo systemctl enable #{service}.service")
        run_remote("sudo systemctl restart #{service}.service")

        raise 'not running' unless service_running?(service)
      rescue StandardError => e
        sleep(5)
        raise 'not running' unless service_running?(service)
      end

      def files_same?(path, data)
        nofail do
          md5local = Digest::MD5.hexdigest(data + "\n")
          md5remote = run_remote("sudo md5sum #{path}").split(' ').first

          return md5local == md5remote
        end
      end

      def write_file_local(path, data)
        run_local("rm #{path}")
        File.open(path, 'w+') { |f| f << data; f << "\n" }
      end

      def write_file(path, data)
        # do nothing if the files are the same
        return if files_same?(path, data)

        # create remote dir if it doesn't exist
        unless run_remote("sudo [ -d #{File.dirname(path)} ]")
          nofail { run_remote("mkdir -p #{File.dirname(path)}") } || run_remote("sudo mkdir -p #{File.dirname(path)}")
        end

        # setup tmp files for copy
        local_tmp_file = File.expand_path(File.join(local_dir, 'tmp', 'file_to_upload'))
        remote_tmp_file = '/tmp/uploaded_file'

        # copy over file
        write_file_local(local_tmp_file, data)
        run_local("scp -i #{Secrets.id_rsa_path} #{local_tmp_file} #{remote_user}@#{ipv4}:#{remote_tmp_file}")
        run_remote("sudo cp #{remote_tmp_file} #{path}")
      end
    end
  end
end
