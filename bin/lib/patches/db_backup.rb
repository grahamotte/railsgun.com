module Patches
  class DbBackup < Base
    class << self
      def needed?
        Instance.exists?
      end

      def apply
        path = "#{Const.home}/#{Const.db_name}_#{Time.now.to_i}.sql"
        Cmd.remote("/usr/bin/pg_dump -U #{Instance.username} --clean #{Const.db_name} > #{path}")
        bb.upload(path)

        bb
          .backup_names
          .select { |x| x.split('.').first.split('_').last.to_i < (Time.now.to_i - 86400 * 30) }
          .each { |x| puts "rm #{x}"; bb.delete(x) }
      ensure
        Cmd.remote("rm -f #{path}")
      end

      private

      def bb
        @bb ||= Vendors::Backblaze.new
      end
    end
  end
end
