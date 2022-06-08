module Patches
  class InstallHtop < Base
    class << self
      def needed?
        !installed?(:htop)
      end

      def apply
        Cmd.remote("#{yay_prefix} -S htop")
      end
    end
  end
end
