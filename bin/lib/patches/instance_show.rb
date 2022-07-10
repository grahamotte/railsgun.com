module Patches
  class InstanceShow < Base
    class << self
      def needed?
        Instance.exists?
      end

      def apply
        pp Instance.show
      end
    end
  end
end
