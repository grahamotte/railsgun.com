module Patches
  class SyncDeploymentCode < Base
    class << self
      def needed?
        return false unless Instance.exists?
        return true unless remote_dir_exists?

        remote_head = Utils.run_remote("cd #{remote_dir}; git rev-parse HEAD")
        local_head = Utils.run_local("git rev-parse HEAD")
        return true if remote_head != local_head

        false
      end

      def apply
        # push to origin
        Utils.run_local("#{git_prefix} remote remove deployment", bool: true)
        Utils.run_local("#{git_prefix} remote add deployment #{Instance.username}@#{Instance.ipv4}:#{remote_origin_dir}/")
        Utils.run_local("#{git_prefix} push -f deployment master")

        # sync with origin
        Utils.run_remote('sudo mkdir -p /var/www')
        Utils.run_remote('sudo chown -R deploy:deploy /var/www')
        Utils.run_remote("git clone #{remote_origin_dir} #{remote_dir}") unless remote_dir_exists?
        Utils.run_remote("cd #{remote_dir}; git fetch")
        Utils.run_remote("cd #{remote_dir}; git checkout -- .")
        Utils.run_remote("cd #{remote_dir}; git reset --hard origin/master")
      end

      # ---

      def git_prefix
        "GIT_SSH_COMMAND='ssh -i #{Secrets.id_rsa_path}' git"
      end

      def remote_origin_dir
        "/home/#{Instance.username}/#{Utils.domain_name}.git"
      end

      def remote_dir_exists?
        Utils.nofail do
          !!Utils.run_remote("cd #{remote_dir}; git rev-parse --is-inside-work-tree")
        end
      end
    end
  end
end
