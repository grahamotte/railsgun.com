module Patches
  class InstanceDestroy < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts("does not exist.")) unless Instance.exists?

        Instance.destroy
      end
    end
  end
end
