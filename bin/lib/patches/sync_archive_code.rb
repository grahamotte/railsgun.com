module Patches
  class SyncArchiveCode < Base
    class << self
      def needed?
        Utils.run_local("git ls-remote -h #{archive_repo} HEAD", bool: true)
      end

      def apply
        Utils.run_local('git remote remove archive', bool: true)
        Utils.run_local("git remote add archive #{archive_repo}")
        Utils.run_local('git push -f archive master')
      end

      # ---

      def archive_repo
        "git@github.com:#{Secrets.github_account}/#{Utils.domain_name}.git"
      end
    end
  end
end
