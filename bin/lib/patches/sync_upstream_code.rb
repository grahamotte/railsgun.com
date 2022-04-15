module Patches
  class SyncUpstreamCode < Base
    class << self
      def always_needed?
        true
      end

      def apply
        run_local('git remote remove upstream', just_status: true)
        run_local("git remote add upstream git@github.com:#{account}/railsgun.com.git")
      end

      # ---

      def account
        'grahamotte'
      end
    end
  end
end
