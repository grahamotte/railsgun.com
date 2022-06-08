module Patches
  class WritePacmanConfig < Base
    class << self
      def apply
        Text.write_remote("/etc/pacman.conf", pacman_conf)
      end

      # ---

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
