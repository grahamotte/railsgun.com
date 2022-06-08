module Patches
  class MakeKnown < Base
    class << self
      def apply
        Cmd.local("ssh-keygen -R #{Instance.ipv4}")
        Cmd.local("ssh-keygen -R #{Utils.domain_name}")
        Cmd.local("ssh-keyscan -H #{Instance.ipv4} >> ~/.ssh/known_hosts", bool: true)
        Cmd.local("ssh-keyscan -H #{Utils.domain_name} >> ~/.ssh/known_hosts", bool: true)
      end
    end
  end
end
