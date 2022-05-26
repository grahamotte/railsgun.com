module Patches
  class InstanceCreate < Base
    class << self
      def apply
        return(puts('already exists.')) if Instance.exists?

        Instance.create
      end
    end
  end
end
