module Patches
  class DbClone < Base
    class << self
      def apply
        return(puts('does not exist.')) unless Instance.exists?

        Utils.run_remote("rm -f ~/#{project}_production.sql")
        Utils.run_remote("pg_dump -U #{Instance.username} --clean #{project}_production > ~/#{project}_production.sql")
        Utils.run_local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{Instance.username}@#{Instance.ipv4}:~/#{project}_production.sql #{local_dir}/tmp/#{project}_production.sql")
        Utils.run_remote("rm -f ~/#{project}_production.sql")
        Utils.run_local("psql #{project}_development < #{local_dir}/tmp/#{project}_production.sql")
        Utils.run_local("rm #{local_dir}/tmp/#{project}_production.sql")
        Utils.run_remote("rm -f ~/#{project}_production.sql")
      end
    end
  end
end
