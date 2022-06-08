module Patches
  class CleanCaches < Base
    class << self
      def apply
        Cmd.remote('yay -Rsn --noconfirm $(yay -Qdtq)', bool: true)
        Cmd.remote('sudo pacman -Sc --noconfirm')
        Cmd.remote('yay -Sc --noconfirm')
        Cmd.remote('sudo journalctl --vacuum-size=500M')
      end
    end
  end
end
