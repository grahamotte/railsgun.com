class Cmd
  class << self
    def remote(cmd, bool: false)
      call(cmd, user: Instance.username, host: Instance.ipv4, bool: bool)
    end

    def local(cmd, bool: false)
      call(cmd, user: `whoami`.chomp, host: 'localhost', bool: bool)
    end

    def call(cmd, user:, host:, bool: false)
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

      return code.zero? if bool
      raise "error code #{code}" unless code.zero?

      text
    end
  end
end
