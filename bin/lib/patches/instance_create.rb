module Patches
  class InstanceCreate < Base
    class << self
      def needed?
        !Instance.exists?
      end

      def apply
        Instance.create
      end
    end
  end
end
