module Patches
  class SystemUpdate < Base
    class << self
      def always_needed?
        true
      end

      def apply
        run_remote('sudo curl -L -o /etc/pacman.d/mirrorlist "https://archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4"')
        run_remote("sudo sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist")
        run_remote("#{yay_prefix} -Sy archlinux-keyring")
        run_remote("#{yay_prefix} -Syu")
      end
    end
  end
end
