module Patches
  class InstanceCreate < Base
    class << self
      def always_needed?
        true
      end

      def apply
        return(puts('instance already exists.')) if instance

        linode_req(
          method: :post,
          url: 'https://api.linode.com/v4/linode/instances',
          payload: {
            region: Config.instance_region || 'us-west',
            image: 'linode/arch',
            label: host,
            type: Config.instance_size || 'g6-nanode-1',
            authorized_keys: [Secrets.id_rsa_pub],
            root_pass: SecureRandom.hex[0..16],
            tags: ['keep'],
          }.to_json,
        )

        loop do
          sleep(4)
          @instance = nil
          break if instance.dig('status') == 'running'
        end

        sleep(16)
      end
    end
  end
end
