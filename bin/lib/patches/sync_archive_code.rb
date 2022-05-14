module Patches
  class SyncArchiveCode < Base
    class << self
      def needed?
        run_local("git ls-remote -h #{archive_repo} HEAD", just_status: true)
      end

      def apply
        run_local('git remote remove archive', just_status: true)
        run_local("git remote add archive #{archive_repo}")
        run_local('git push -f archive master')
      end

      # ---

      def archive_repo
        "git@github.com:#{Secrets.github_account}/#{host}.git"
      end
    end
  end
end
