module Patches
  class SyncUpstreamCode < Base
    class << self
      def apply
        Utils.run_local('git remote remove upstream', bool: true)
        Utils.run_local("git remote add upstream git@github.com:#{account}/railsgun.com.git")
      end

      # ---

      def account
        'grahamotte'
      end
    end
  end
end
