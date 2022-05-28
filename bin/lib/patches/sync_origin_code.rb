module Patches
  class SyncOriginCode < Base
    class << self
      def apply
        Utils.run_local('git remote remove origin', bool: true)
      end
    end
  end
end
