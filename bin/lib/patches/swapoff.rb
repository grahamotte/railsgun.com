module Patches
  class Swapoff < Base
    class << self
      def always_needed?
        true
      end

      def apply
        run_remote('sudo /sbin/swapoff -a')
      end
    end
  end
end
