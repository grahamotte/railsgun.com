module Patches
  class Swapoff < Base
    class << self
      def apply
        Utils.run_remote('sudo /sbin/swapoff -a')
      end
    end
  end
end
