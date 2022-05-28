module Patches
  class InstallAsdf < Base
    class << self
      def needed?
        !Utils.run_remote("#{asdf_prefix} --version", bool: true)
      end

      def apply
        Utils.run_remote("rm -rf ~/.asdf")
        Utils.run_remote("sudo rm -rf /opt/asdf-vm/")
        Utils.run_remote("#{yay_prefix} -S curl git base-devel")
        Utils.run_remote("git clone https://aur.archlinux.org/asdf-vm.git")
        Utils.run_remote("cd asdf-vm && makepkg -si --noconfirm")
        Utils.run_remote("rm -r ~/asdf-vm")
      end
    end
  end
end
