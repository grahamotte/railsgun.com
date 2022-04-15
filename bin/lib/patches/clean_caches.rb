module Patches
  class CleanCaches < Base
    class << self
      def always_needed?
        true
      end

      def apply
        subsection('clearing cached packages') do
          run_remote('yay -Rsn --noconfirm $(yay -Qdtq)', just_status: true)
          run_remote('sudo pacman -Sc --noconfirm')
          run_remote('yay -Sc --noconfirm')
        end

        subsection('vacuuming journal') do
          run_remote('sudo journalctl --vacuum-size=500M')
        end
      end
    end
  end
end
