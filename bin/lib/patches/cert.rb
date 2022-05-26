module Patches
  class Cert < Base
    class << self
      def needed?
        le_subdomains = Utils.nofail do
          Utils.run_remote("sudo cat /etc/letsencrypt/live/#{host}/fullchain.pem | openssl x509 -noout -ext subjectAltName")
            .split
            .select { |x| x.start_with?('DNS:') }
            .map { |x| x.gsub('DNS:', '') }
            .map { |x| x.gsub(',', '') }
        end

        return true unless le_subdomains
        return true unless le_subdomains.sort == subdomains.sort

        expires_on = Utils.nofail do
          Utils.run_remote("sudo cat /etc/letsencrypt/live/#{host}/fullchain.pem | openssl x509 -noout -enddate")
            .then { |x| x.gsub('notAfter=', '') }
            .then { |x| Date.parse(x) - 14 }
        end

        return true unless expires_on
        return true if expires_on < Date.today

        false
      end

      def apply
        Utils.run_remote("#{yay_prefix} -S certbot certbot-nginx nginx")
        Utils.run_remote('sudo systemctl stop nginx.service')
        write_file('/etc/nginx/nginx.conf', default_nginx_conf)
        Utils.run_remote('sudo fuser -k 80/tcp || true')
        Utils.run_remote('sudo systemctl start nginx.service')
        Utils.run_remote('sudo nginx -t')
        Utils.run_remote("sudo rm -rf /etc/letsencrypt")
        Utils.run_remote("sudo certbot --nginx certonly --non-interactive --agree-tos -m cert@#{host} #{subdomains.map { |x| "-d #{x}" }.join(' ')}")
        Utils.run_remote('sudo systemctl stop nginx.service')
      end

      # ---

      def default_nginx_conf
        RestClient
          .get('https://gist.githubusercontent.com/nishantmodak/d08aae033775cb1a0f8a/raw/ebea0ae66e0a0188009accae2acba88cc646ddcd/nginx.conf.default')
          .body
      end
    end
  end
end
