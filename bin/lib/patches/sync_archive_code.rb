module Patches
  class SyncArchiveCode < Base
    class << self
      def needed?
        return false if archive_repo.blank?

        Cmd.local("#{git_prefix} ls-remote -h #{archive_repo} HEAD", bool: true)
      end

      def apply
        Cmd.local("#{git_prefix} remote remove archive", bool: true)
        Cmd.local("#{git_prefix} remote add archive #{archive_repo}")
        Cmd.local("#{git_prefix} push -f archive master")
      end

      private

      def git_prefix
        "GIT_SSH_COMMAND='ssh -i #{Secrets.id_rsa_path}' git"
      end

      def archive_repo
        return 'git@github.com:grahamotte/railsgun.com.git' if Const.domain == 'railsgun.com'

        Config.archive_repo
      end
    end
  end
end
