module Patches
  class SyncAllCode < Base
    class << self
      def leaf?
        false
      end

      def apply
        Patches::SyncOriginCode.call
        Patches::SyncUpstreamCode.call
        Patches::SyncArchiveCode.call
        Patches::CreateDeploymentOrigin.call
        Patches::SyncDeploymentCode.call
      end
    end
  end
end
