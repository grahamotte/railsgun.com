module Patches
  class InstallUtils < Base
    class << self
      def needed?
        return true unless Instance.installed?(:curl)
        return true unless Instance.installed?(:htop)
      end

      def apply
        Cmd.remote("#{Const.yay} -S curl")
        Cmd.remote("#{Const.yay} -S htop")
      end
    end
  end
end
