module Patches
  class SyncOriginCode < Base
    class << self
      def apply
        Utils.run_local('git remote remove origin', just_status: true)
      end
    end
  end
end
