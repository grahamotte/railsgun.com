module Patches
  class GitAll < Base
    class << self
      def leaf?
        false
      end

      def apply
        Patches::GitOrigin.call # repo on the server
        Patches::GitUpstream.call # railsgun.com
        Patches::GitArchive.call # github backup
        Patches::GitDeployment.call # deployment clone of origin
      end
    end
  end
end
