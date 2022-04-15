module Patches
  class Plausible < Base
    class << self
      def needed?
        false
      end

      def apply
        # must install manually, for now...
        #
        # [deploy@localhost ~]$ yay -S docker docker-compose
        # ...reboot the server...
        # [deploy@localhost hosting]$ sudo systemctl start docker
        # [deploy@localhost ~]$ git clone https://github.com/plausible/hosting
        # [deploy@localhost hosting]$ vim plausible-conf.env
        #   ADMIN_USER_EMAIL=...
        #   ADMIN_USER_NAME=...
        #   ADMIN_USER_PWD=...
        #   BASE_URL=https://domain
        #   SECRET_KEY_BASE= openssl rand -base64 64 | tr -d '\n' ; echo
        # [deploy@localhost hosting]$ sudo docker-compose up -d
        # <script defer data-domain="<%= Rails.configuration.domain %>" src="https://pl.<%= Rails.configuration.domain %>/js/plausible.js"></script>
      end
    end
  end
end
