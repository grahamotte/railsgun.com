module Patches
  class InstallAsdf < Base
    class << self
      def needed?
        !Cmd.remote("#{asdf_prefix} --version", bool: true)
      end

      def apply
        Cmd.remote("rm -rf ~/.asdf")
        Cmd.remote("sudo rm -rf /opt/asdf-vm/")
        Cmd.remote("#{yay_prefix} -S curl git base-devel")
        Cmd.remote("git clone https://aur.archlinux.org/asdf-vm.git")
        Cmd.remote("cd asdf-vm && makepkg -si --noconfirm")
        Cmd.remote("rm -r ~/asdf-vm")
      end
    end
  end
end
