module Patches
  class InstallCurl < Base
    class << self
      def needed?
        !Instance.installed?(:curl)
      end

      def apply
        Cmd.remote("#{Const.yay} -S curl")
      end
    end
  end
end
