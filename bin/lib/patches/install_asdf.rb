module Patches
  class InstallAsdf < Base
    class << self
      def needed?
        !run_remote("#{asdf_prefix} --version", just_status: true)
      end

      def apply
        run_remote("rm -rf ~/.asdf")
        run_remote("sudo rm -rf /opt/asdf-vm/")
        run_remote("#{yay_prefix} -S curl git base-devel")
        run_remote("git clone https://aur.archlinux.org/asdf-vm.git")
        run_remote("cd asdf-vm && makepkg -si --noconfirm")
        run_remote("rm -r ~/asdf-vm")
      end
    end
  end
end
