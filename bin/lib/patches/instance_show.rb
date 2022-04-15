module Patches
  class InstanceShow < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts("no instance exists.")) unless instance

        pp instance
      end
    end
  end
end
