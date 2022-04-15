module Patches
  class InstanceDestroy < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts("no instance exists.")) unless instance

        linode_req(
          method: :delete,
          url: "https://api.linode.com/v4/linode/instances/#{instance.dig('id')}",
        )
      end
    end
  end
end
