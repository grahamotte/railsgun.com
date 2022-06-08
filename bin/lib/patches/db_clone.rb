module Patches
  class DbClone < Base
    class << self
      def apply
        return(puts('does not exist.')) unless Instance.exists?

        Cmd.remote("rm -f ~/#{Const.project}_production.sql")
        Cmd.remote("pg_dump -U #{Instance.username} --clean #{Const.project}_production > ~/#{Const.project}_production.sql")
        Cmd.local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{Instance.username}@#{Instance.ipv4}:~/#{Const.project}_production.sql #{Const.local_root}/tmp/#{Const.project}_production.sql")
        Cmd.remote("rm -f ~/#{Const.project}_production.sql")
        Cmd.local("psql #{Const.project}_development < #{Const.local_root}/tmp/#{Const.project}_production.sql")
        Cmd.local("rm #{Const.local_root}/tmp/#{Const.project}_production.sql")
        Cmd.remote("rm -f ~/#{Const.project}_production.sql")
      end
    end
  end
end
