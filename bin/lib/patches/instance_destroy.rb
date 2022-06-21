module Patches
  class InstanceDestroy < Base
    class << self
      def needed?
        Instance.exists?
      end

      def apply
        Instance.destroy
      end
    end
  end
end
