class Const
  class << self
    def domain
      File.basename(File.dirname(File.dirname(__dir__)))
    end

    def project
      domain.split('.').first
    end

    def local_root
      File.dirname(File.dirname(__dir__))
    end

    def remote_root
      "/var/www/#{domain}"
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
        .map { |x| "#{x}.#{Const.domain}" }
        .unshift(Const.domain)
    end

    def job_concurrency
      Config.job_concurrency || 3
    end

    def remote_rclone_conf_path
      "/home/#{Instance.username}/.config/rclone/rclone.conf"
    end

    def asdf
      '. /opt/asdf-vm/asdf.sh; asdf'
    end

    def asdf_exec
      '. /opt/asdf-vm/asdf.sh; asdf exec'
    end

    def yay
      'yay --nodiffmenu --noeditmenu --nouseask --nocleanmenu --noupgrademenu --noconfirm'
    end

    def rails
      env = {
        rails_env: :production,
        rails_max_threads: 32,
        malloc_arena_max: 2,
        queue: '*',
      }.map { |k, v| "export #{k.to_s.upcase}=#{v}" }.join('; ')

      "cd #{remote_root}; #{env}; #{asdf_exec} bundle exec"
    end

    def influx_token
      Cmd
        .remote('influx auth list --json | grep token')
        .then { |x| JSON.parse("{#{x.gsub(',', '')}}") }
        .dig('token')
    end
  end
end
