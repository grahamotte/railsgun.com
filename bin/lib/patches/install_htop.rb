module Patches
  class InstallHtop < Base
    class << self
      def needed?
        !installed?(:htop)
      end

      def apply
        Utils.run_remote("#{yay_prefix} -S htop")
      end
    end
  end
end
