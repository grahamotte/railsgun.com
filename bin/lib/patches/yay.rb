module Patches
  class Yay < Base
    class << self
      def needed?
        return true unless Text.remote_md5_eq?('/etc/pacman.conf', pacman_conf)
        return true unless Instance.installed?(:yay)

        false
      end

      def apply
        Text.write_remote("/etc/pacman.conf", pacman_conf)

        Cmd.remote("sudo pacman -Syu --noconfirm")
        Cmd.remote('sudo pacman -S --noconfirm git base-devel')
        Cmd.remote('git clone https://aur.archlinux.org/yay.git')
        Cmd.remote('cd ~/yay; yes | makepkg -si')
        Cmd.remote('rm -rf ~/yay')
      end

      private

      def pacman_conf
        <<~TEXT
          [options]
          HoldPkg = pacman glibc
          Architecture = auto
          IgnorePkg = openssh
          CheckSpace
          SigLevel = Required DatabaseOptional
          LocalFileSigLevel = Optional

          [core]
          Include = /etc/pacman.d/mirrorlist

          [extra]
          Include = /etc/pacman.d/mirrorlist

          [community]
          Include = /etc/pacman.d/mirrorlist
        TEXT
      end
    end
  end
end
