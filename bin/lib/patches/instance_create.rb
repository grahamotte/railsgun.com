module Patches
  class InstanceCreate < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts('already exists.')) if Instance.exists?

        Instance.create
      end
    end
  end
end
