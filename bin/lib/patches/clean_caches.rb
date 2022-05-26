module Patches
  class CleanCaches < Base
    class << self
      def apply
        run_remote('yay -Rsn --noconfirm $(yay -Qdtq)', just_status: true)
        run_remote('sudo pacman -Sc --noconfirm')
        run_remote('yay -Sc --noconfirm')
        run_remote('sudo journalctl --vacuum-size=500M')
      end
    end
  end
end
