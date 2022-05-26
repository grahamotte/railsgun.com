module Patches
  class Dns < Base
    class << self
      def needed?
        to_id = ->(r) { "#{r['type'] || r[:type]} #{r['name'] || r[:name]} #{r['content'] || r[:content]}" }

        existing_records = cf_dns_records.map(&to_id).sort
        desired_records = dns_config.map(&to_id).sort

        existing_records != desired_records
      end

      def apply
        if cf_zone
          Utils.req(
            url: "https://api.cloudflare.com/client/v4/zones/#{cf_zone.dig(:id)}",
            method: :delete,
            headers: { Authorization: "Bearer #{Secrets.cloudflare_token}", content_type: :json, accept: :json },
          )
        end

        cloudflare_zone = Utils.req(
          url: "https://api.cloudflare.com/client/v4/zones",
          method: :post,
          payload: { name: Utils.domain_name }.to_json,
          headers: { Authorization: "Bearer #{Secrets.cloudflare_token}", content_type: :json, accept: :json },
        )

        dns_config.each do |record|
          Utils.req(
            url: "https://api.cloudflare.com/client/v4/zones/#{cloudflare_zone.dig(:result, :id)}/dns_records",
            method: :post,
            payload: record.to_json,
            headers: { Authorization: "Bearer #{Secrets.cloudflare_token}", content_type: :json, accept: :json },
          )
        end

        sleep(15) # give it a bit to sync up
      end

      # ---

      def dns_config
        [
          *subdomains.map { |x| { type: 'A', name: x, content: Instance.ipv4, proxied: false, ttl: 1 } },
          { type: 'MX', name: Utils.domain_name, priority: 10, content: 'in1-smtp.messagingengine.com', proxied: false, ttl: 1 },
          { type: 'MX', name: Utils.domain_name, priority: 20, content: 'in2-smtp.messagingengine.com', proxied: false, ttl: 1 },
          { type: 'CNAME', name: "fm1._domainkey.#{Utils.domain_name}", content: "fm1.#{Utils.domain_name}.dkim.fmhosted.com", proxied: false, ttl: 1 },
          { type: 'CNAME', name: "fm2._domainkey.#{Utils.domain_name}", content: "fm2.#{Utils.domain_name}.dkim.fmhosted.com", proxied: false, ttl: 1 },
          { type: 'CNAME', name: "fm3._domainkey.#{Utils.domain_name}", content: "fm3.#{Utils.domain_name}.dkim.fmhosted.com", proxied: false, ttl: 1 },
          { type: 'TXT', name: Utils.domain_name, content: "v=spf1 include:spf.messagingengine.com ?all", proxied: false, ttl: 1 },
        ]
      end

      def cf_zone
        Utils.req(
          method: :get,
          url: "https://api.cloudflare.com/client/v4/zones",
          headers: { Authorization: "Bearer #{Secrets.cloudflare_token}", content_type: :json, accept: :json },
        ).dig(:result).find { |x| x[:name] == Utils.domain_name }
      end

      def cf_dns_records
        return [] if cf_zone.nil?

        Utils.req(
          method: :get,
          url: "https://api.cloudflare.com/client/v4/zones/#{cf_zone[:id]}/dns_records",
          headers: { Authorization: "Bearer #{Secrets.cloudflare_token}", content_type: :json, accept: :json },
        ).dig(:result)
      end
    end
  end
end
