module Patches
  class DbBackup < Base
    class << self
      def apply
        return(puts('does not exist.')) unless Instance.exists?

        db_name = "#{project}_production"
        file = "/mnt/dbs/#{db_name}_#{Time.now.to_i}.sql"

        run_remote("pg_dump -U #{Instance.username} --clean #{db_name} > #{file}")
        run_remote("stat #{file}")
      end
    end
  end
end
