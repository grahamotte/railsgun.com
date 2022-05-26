module Patches
  class InstallYay < Base
    class << self
      def needed?
        !installed?(:yay)
      end

      def apply
        Utils.run_remote("sudo pacman -Syu --noconfirm")
        Utils.run_remote('sudo pacman -S --noconfirm git base-devel')
        Utils.run_remote('git clone https://aur.archlinux.org/yay.git')
        Utils.run_remote('cd ~/yay; yes | makepkg -si')
        Utils.run_remote('rm -rf ~/yay')
      end
    end
  end
end
