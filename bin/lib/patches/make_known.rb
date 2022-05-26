module Patches
  class MakeKnown < Base
    class << self
      def apply
        Utils.run_local("ssh-keygen -R #{Instance.ipv4}")
        Utils.run_local("ssh-keygen -R #{Utils.domain_name}")
        Utils.run_local("ssh-keyscan -H #{Instance.ipv4} >> ~/.ssh/known_hosts", just_status: true)
        Utils.run_local("ssh-keyscan -H #{Utils.domain_name} >> ~/.ssh/known_hosts", just_status: true)
      end
    end
  end
end
