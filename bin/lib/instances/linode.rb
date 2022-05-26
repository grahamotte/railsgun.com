module Instances
  class Linode
    class << self
      def ipv4
        show&.dig(:ipv4)&.first
      end

      def show
        req(method: :get, url: 'https://api.linode.com/v4/linode/instances')
          .dig(:data)
          .find { |i| i.dig(:label) == Instance.host }
      end

      def create
        req(
          method: :post,
          url: 'https://api.linode.com/v4/linode/instances',
          payload: {
            region: Instance.region,
            image: Instance.image,
            label: Instance.host,
            type: Instance.size,
            authorized_keys: [Instance.id_rsa_pub],
            root_pass: Instance.password,
          }.to_json,
        )

        loop do
          sleep(4)
          break if show.dig(:status) == 'running'
        end

        sleep(16)
      end

      def destroy
        req(
          method: :delete,
          url: "https://api.linode.com/v4/linode/instances/#{show.dig(:id)}",
        )
      end

      private

      def req(**params)
        params = params.merge(
          headers: {
            Authorization: "Bearer #{Secrets.linode_token}",
            content_type: :json,
          },
        )

        puts "#{params.dig(:method).to_s.upcase} #{params.dig(:url)} #{params.dig(:payload)}".green

        RestClient::Request.execute(**params).body.then { |x| JSON.parse(x, symbolize_names: true) }
      rescue StandardError => e
        pp e&.http_body
        raise e
      end
    end
  end
end
