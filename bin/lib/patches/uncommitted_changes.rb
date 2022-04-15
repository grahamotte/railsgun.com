module Patches
  class UncommittedChanges < Base
    class << self
      def always_needed?
        true
      end

      def apply
        run_local('git update-index --refresh && git diff-index --quiet HEAD --')
      end
    end
  end
end
