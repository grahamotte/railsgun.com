module Patches
  class DbClone < Base
    class << self
      def needed?
        return false unless Const.backups_setup?
        return false unless Instance.exists?

        true
      end

      def apply
        key = Const.backup_keys.last
        local_path = "#{Const.local_root}/tmp/#{Const.project}_production.sql"
        remote_path = "#{Const.home}/#{key}"

        Cmd.remote("#{Const.yay} -S aws-cli") unless Instance.installed?('aws')
        Cmd.remote("#{Const.aws_cli_s3} cp s3://#{Secrets.backup_bucket.dig('bucket')}/#{key} #{remote_path}")
        Cmd.run("#{Const.yay} -S rsync") unless Instance.installed?('rsync')
        Cmd.local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{Instance.username}@#{Instance.ipv4}:#{remote_path} #{local_path}")
        Cmd.local("psql #{Const.project}_development < #{local_path}")
      ensure
        Cmd.remote("rm -f #{remote_path}")
        Cmd.local("rm -f #{local_path}")
      end
    end
  end
end
