module Patches
  class InstanceDestroy < Base
    class << self
      def apply
        return(puts("does not exist.")) unless Instance.exists?

        Instance.destroy
      end
    end
  end
end
