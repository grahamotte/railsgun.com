module Patches
  class DbClone < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts('does not exist.')) unless Instance.exists?

        subsection('dumping db') do
          run_remote("rm -f ~/#{project}_production.sql")
          run_remote("pg_dump -U #{Instance.username} --clean #{project}_production > ~/#{project}_production.sql")
        end

        subsection('saving prod db to local dev env') do
          run_local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{Instance.username}@#{Instance.ipv4}:~/#{project}_production.sql #{local_dir}/tmp/#{project}_production.sql")
          run_remote("rm -f ~/#{project}_production.sql")
          run_local("psql #{project}_development < #{local_dir}/tmp/#{project}_production.sql")
        end

        subsection('cleaning up') do
          run_local("rm #{local_dir}/tmp/#{project}_production.sql")
          run_remote("rm -f ~/#{project}_production.sql")
        end
      end
    end
  end
end
