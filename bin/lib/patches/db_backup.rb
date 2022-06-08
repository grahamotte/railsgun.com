module Patches
  class DbBackup < Base
    class << self
      def apply
        return(puts('does not exist.')) unless Instance.exists?

        db_name = "#{Utils.project_name}_production"
        file = "/mnt/dbs/#{db_name}_#{Time.now.to_i}.sql"

        Cmd.remote("pg_dump -U #{Instance.username} --clean #{db_name} > #{file}")
        Cmd.remote("stat #{file}")
      end
    end
  end
end
