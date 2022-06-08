module Patches
  class MakeKnown < Base
    class << self
      def apply
        Cmd.local("ssh-keygen -R #{Instance.ipv4}")
        Cmd.local("ssh-keygen -R #{Const.domain}")
        Cmd.local("ssh-keyscan -H #{Instance.ipv4} >> ~/.ssh/known_hosts", bool: true)
        Cmd.local("ssh-keyscan -H #{Const.domain} >> ~/.ssh/known_hosts", bool: true)
      end
    end
  end
end
