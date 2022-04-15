module Patches
  class InstallYay < Base
    class << self
      def needed?
        !installed?(:yay)
      end

      def apply
        run_remote("sudo pacman -Syu --noconfirm")
        run_remote('sudo pacman -S --noconfirm git base-devel')
        run_remote('git clone https://aur.archlinux.org/yay.git')
        run_remote('cd ~/yay; yes | makepkg -si')
        run_remote('rm -rf ~/yay')
      end
    end
  end
end
