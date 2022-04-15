module Patches
  class SyncOriginCode < Base
    class << self
      def always_needed?
        true
      end

      def apply
        run_local('git remote remove origin', just_status: true)
      end
    end
  end
end
