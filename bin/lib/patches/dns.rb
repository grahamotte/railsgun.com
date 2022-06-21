module Patches
  class Dns < Base
    class << self
      def needed?
        to_id = ->(r) { "#{r['type'] || r[:type]} #{r['name'] || r[:name]} #{r['content'] || r[:content]}" }
        existing_records = current_records.map(&to_id).sort
        desired_records = records_config.map(&to_id).sort
        existing_records != desired_records
      end

      def apply
        # create zone
        cf_req(:post, '/zones', { name: Const.domain }.to_json) if zone_id.blank?

        # clear any current records
        current_records.each { |x| cf_req(:delete, "/zones/#{zone_id}/dns_records/#{x[:id]}") }
        sleep(2)

        # setup records
        records_config.each { |x| cf_req(:post, "/zones/#{zone_id}/dns_records", x.to_json) }
        sleep(15)
      end

      private

      def records_config
        [
          *Const.subdomains.map { |x| { type: 'A', name: x, content: Instance.ipv4, proxied: false, ttl: 1 } },
          { type: 'MX', name: Const.domain, priority: 10, content: 'in1-smtp.messagingengine.com', proxied: false, ttl: 1 },
          { type: 'MX', name: Const.domain, priority: 20, content: 'in2-smtp.messagingengine.com', proxied: false, ttl: 1 },
          { type: 'CNAME', name: "fm1._domainkey.#{Const.domain}", content: "fm1.#{Const.domain}.dkim.fmhosted.com", proxied: false, ttl: 1 },
          { type: 'CNAME', name: "fm2._domainkey.#{Const.domain}", content: "fm2.#{Const.domain}.dkim.fmhosted.com", proxied: false, ttl: 1 },
          { type: 'CNAME', name: "fm3._domainkey.#{Const.domain}", content: "fm3.#{Const.domain}.dkim.fmhosted.com", proxied: false, ttl: 1 },
          { type: 'TXT', name: Const.domain, content: "v=spf1 include:spf.messagingengine.com ?all", proxied: false, ttl: 1 },
        ]
      end

      def cf_req(method, path, payload = nil)
        Utils.req(
          url: "https://api.cloudflare.com/client/v4#{path}",
          method: method,
          payload: payload,
          headers: { Authorization: "Bearer #{Secrets.cloudflare_token}", 'Content-Type' => 'application/json' },
        )
      end

      def zone_id
        @zone_id ||= cf_req(:get, '/zones')
          .dig(:result)
          .find { |x| x[:name] == Const.domain }
          &.dig(:id)
      end

      def current_records
        return [] if zone_id.nil?

        cf_req(:get, "/zones/#{zone_id}/dns_records").dig(:result)
      end
    end
  end
end
