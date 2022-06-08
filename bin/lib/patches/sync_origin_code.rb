module Patches
  class SyncOriginCode < Base
    class << self
      def apply
        Cmd.local('git remote remove origin', bool: true)
      end
    end
  end
end
