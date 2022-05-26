module Patches
  class InstallCurl < Base
    class << self
      def needed?
        !installed?(:curl)
      end

      def apply
        Utils.run_remote("#{yay_prefix} -S curl")
      end
    end
  end
end
