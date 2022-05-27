module Patches
  class SystemUpdate < Base
    class << self
      def needed?
        Cache.read(:system_updated_recently).blank?
      end

      def apply
        Utils.run_remote('sudo curl -L -o /etc/pacman.d/mirrorlist "https://archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4"')
        Utils.run_remote("sudo sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist")
        Utils.run_remote("#{yay_prefix} -Sy archlinux-keyring")
        Utils.run_remote("#{yay_prefix} -Syu")

        Cache.write(:system_updated_recently, true, 86400)
      end
    end
  end
end
