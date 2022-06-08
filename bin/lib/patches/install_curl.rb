module Patches
  class InstallCurl < Base
    class << self
      def needed?
        !Instance.installed?(:curl)
      end

      def apply
        Cmd.remote("#{yay_prefix} -S curl")
      end
    end
  end
end
