module Patches
  class DbClone < Base
    class << self
      def apply
        return(puts('does not exist.')) unless Instance.exists?

        Utils.run_remote("rm -f ~/#{Utils.project_name}_production.sql")
        Utils.run_remote("pg_dump -U #{Instance.username} --clean #{Utils.project_name}_production > ~/#{Utils.project_name}_production.sql")
        Utils.run_local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{Instance.username}@#{Instance.ipv4}:~/#{Utils.project_name}_production.sql #{local_dir}/tmp/#{Utils.project_name}_production.sql")
        Utils.run_remote("rm -f ~/#{Utils.project_name}_production.sql")
        Utils.run_local("psql #{Utils.project_name}_development < #{local_dir}/tmp/#{Utils.project_name}_production.sql")
        Utils.run_local("rm #{local_dir}/tmp/#{Utils.project_name}_production.sql")
        Utils.run_remote("rm -f ~/#{Utils.project_name}_production.sql")
      end
    end
  end
end
