module Patches
  class CleanCaches < Base
    class << self
      def apply
        Utils.run_remote('yay -Rsn --noconfirm $(yay -Qdtq)', bool: true)
        Utils.run_remote('sudo pacman -Sc --noconfirm')
        Utils.run_remote('yay -Sc --noconfirm')
        Utils.run_remote('sudo journalctl --vacuum-size=500M')
      end
    end
  end
end
