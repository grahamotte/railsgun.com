module Patches
  class MakeKnown < Base
    class << self
      def always_needed?
        true
      end

      def apply
        subsection('removing hosts') do
          run_local("ssh-keygen -R #{Instance.ipv4}")
          run_local("ssh-keygen -R #{host}")
        end

        subsection('adding hosts') do
          run_local("ssh-keyscan -H #{Instance.ipv4} >> ~/.ssh/known_hosts", just_status: true)
          run_local("ssh-keyscan -H #{host} >> ~/.ssh/known_hosts", just_status: true)
        end
      end
    end
  end
end
