module Patches
  class InstallYay < Base
    class << self
      def needed?
        !Instance.installed?(:yay)
      end

      def apply
        Cmd.remote("sudo pacman -Syu --noconfirm")
        Cmd.remote('sudo pacman -S --noconfirm git base-devel')
        Cmd.remote('git clone https://aur.archlinux.org/yay.git')
        Cmd.remote('cd ~/yay; yes | makepkg -si')
        Cmd.remote('rm -rf ~/yay')
      end
    end
  end
end
