class Utils
  class << self
    def req(**params)
      puts "#{params.dig(:method).to_s.upcase} #{params.dig(:url)} #{params.dig(:payload)}".green

      RestClient::Request
        .execute(**params)
        .body
        .then { |x| JSON.parse(x, symbolize_names: true) }
    rescue StandardError => e
      pp e&.http_body
      raise e
    end

    def Utils.run_remote(cmd, *opts, just_status: false)
      run(cmd, *opts, user: Instance.username, host: Instance.ipv4, just_status: just_status)
    end

    def Utils.run_local(cmd, *opts, just_status: false)
      run(cmd, *opts, user: `whoami`.chomp, host: 'localhost', just_status: just_status)
    end

    def run(cmd, *opts, user:, host:, just_status: false)
      cmd = cmd % opts.map { |o| Shellwords.escape(o) } if opts.any?

      puts "RUN #{user}@#{host} #{cmd}".cyan

      text = ""
      code = 0

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
  end
end
