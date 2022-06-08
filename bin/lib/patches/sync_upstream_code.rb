module Patches
  class SyncUpstreamCode < Base
    class << self
      def apply
        Cmd.local('git remote remove upstream', bool: true)
        Cmd.local("git remote add upstream git@github.com:#{account}/railsgun.com.git")
      end

      # ---

      def account
        'grahamotte'
      end
    end
  end
end
