module Patches
  class SyncArchiveCode < Base
    class << self
      def needed?
        return false if archive_repo.blank?

        Utils.run_local("git ls-remote -h #{archive_repo} HEAD", bool: true)
      end

      def apply
        Utils.run_local('git remote remove archive', bool: true)
        Utils.run_local("git remote add archive #{archive_repo}")
        Utils.run_local('git push -f archive master')
      end

      private

      def archive_repo
        return 'git@github.com:grahamotte/railsgun.com.git' if Utils.domain_name == 'railsgun.com'

        Config.archive_repo
      end
    end
  end
end
