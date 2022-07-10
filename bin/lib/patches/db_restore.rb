module Patches
  class DbRestore < Base
    class << self
      def needed?
        return false unless Const.backups_setup?
        return false unless Instance.exists?

        true
      end

      def apply
        Cmd.remote("#{Const.yay} -S aws-cli") unless Instance.installed?('aws')

        key = Const.backup_keys.last
        path = "#{Const.home}/#{key}"

        Cmd.remote("#{Const.aws_cli_s3} cp s3://#{Secrets.backup_bucket.dig('bucket')}/#{key} #{path}")
        Cmd.remote("psql #{Const.db_name} < #{path}")
      ensure
        Cmd.remote("rm -f #{path}")
      end
    end
  end
end
