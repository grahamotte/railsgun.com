module Patches
  class DbRestore < Base
    class << self
      def needed?
        return false unless Instance.exists?
        return false unless bb.authorized?

        true
      end

      def apply
        path = "#{Const.home}/#{bb.latest_backup_key}"
        bb.download(bb.latest_backup_key, path)
        Cmd.remote("psql #{Const.db_name} < #{path}")
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
