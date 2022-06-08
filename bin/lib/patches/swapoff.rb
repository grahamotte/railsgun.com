module Patches
  class Swapoff < Base
    class << self
      def apply
        Cmd.remote('sudo /sbin/swapoff -a')
      end
    end
  end
end
