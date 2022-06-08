module Patches
  class InstallHtop < Base
    class << self
      def needed?
        !Instance.installed?(:htop)
      end

      def apply
        Cmd.remote("#{Const.yay} -S htop")
      end
    end
  end
end
