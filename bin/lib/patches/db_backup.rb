module Patches
  class DbBackup < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts('no instance.')) unless instance

        db_name = "#{project}_production"
        file = "/mnt/dbs/#{db_name}_#{Time.now.to_i}.sql"

        subsection('backing up') do
          run_remote("pg_dump -U #{remote_user} --clean #{db_name} > #{file}")
        end

        subsection('checking backup') do
          run_remote("stat #{file}")
        end
      end
    end
  end
end
