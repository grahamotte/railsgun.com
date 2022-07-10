module Patches
  class DbBackup < Base
    class << self
      def needed?
        return false unless Const.backups_setup?
        return false unless Instance.exists?

        true
      end

      def apply
        key = "#{Const.db_name}_#{Time.now.to_i}.sql"
        path = "#{Const.home}/#{key}"

        Cmd.run("#{Const.yay} -S aws-cli") unless Instance.installed?('aws')
        Cmd.remote("/usr/bin/pg_dump -U #{Instance.username} --clean #{Const.db_name} > #{path}")
        Cmd.remote("#{Const.aws_cli_s3} cp #{path} s3://#{Secrets.backup_bucket.dig('bucket')}/#{key}")

        Const
          .backup_keys
          .select { |x| x.split('.').first.split('_').last.to_i < (Time.now.to_i - 86400 * 30) }
          .each { |x| Cmd.remote("#{Const.aws_cli_s3} rm s3://#{Secrets.backup_bucket.dig('bucket')}/#{x}") }
      ensure
        Cmd.remote("rm -f #{path}")
      end
    end
  end
end
