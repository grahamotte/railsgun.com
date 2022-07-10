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

    def db_name
      "#{project}_production"
    end

    def home
      "/home/#{Instance.username}"
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
        .map { |x| "#{x}.#{domain}" }
        .unshift(domain)
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

    def backups_setup?
      return false if Secrets.backup_bucket.dig('access_key_id').blank?
      return false if Secrets.backup_bucket.dig('secret_access_key').blank?
      return false if Secrets.backup_bucket.dig('bucket').blank?
      return false if Secrets.backup_bucket.dig('endpoint').blank?

      true
    end

    def backup_keys
      Cmd
        .remote("#{aws_cli_s3} ls --recursive #{Secrets.backup_bucket.dig('bucket')} | grep #{db_name}")
        .split("\n")
        .map { |x| x.split.last }
        .select { |x| x.start_with?(db_name) }
        .sort
    end

    def aws_cli_s3
      [
        "export AWS_ACCESS_KEY_ID=#{Secrets.backup_bucket.dig('access_key_id')};",
        "export AWS_SECRET_ACCESS_KEY=#{Secrets.backup_bucket.dig('secret_access_key')};",
        "aws --endpoint-url #{Secrets.backup_bucket.dig('endpoint')}",
        "s3",
      ].join(' ')
    end
  end
end
