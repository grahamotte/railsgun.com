module Patches
  class DbClone < Base
    class << self
      def needed?
        return false unless Instance.exists?
        return false unless bb.authorized?

        true
      end

      def apply
        remote_path = "#{Const.home}/#{bb.latest_backup_key}"
        local_path = "#{Const.local_root}/tmp/#{Const.project}_production.sql"

        bb.download(bb.latest_backup_key, remote_path)

        [
          "rsync -av",
          "-e \"ssh -i #{Secrets.id_rsa_path}\"",
          "#{Instance.username}@#{Instance.ipv4}:#{remote_path}",
          local_path,
        ].join(' ').then { |x| Cmd.local(x) }

        Cmd.local("psql #{Const.project}_development < #{local_path}")
      ensure
        Cmd.remote("rm -f #{remote_path}")
        Cmd.local("rm -f #{local_path}")
      end

      private

      def bb
        @bb ||= Vendors::Backblaze.new
      end
    end
  end
end
