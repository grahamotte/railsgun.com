module Patches
  class SyncDeploymentCode < Base
    class << self
      def needed?
        return false unless instance

        return true unless remote_dir_exists?

        remote_head = run_remote("cd #{remote_dir}; git rev-parse HEAD")
        local_head = run_local("git rev-parse HEAD")
        return true if remote_head != local_head

        false
      end

      def apply
        # push to origin
        run_local("#{git_prefix} remote remove deployment", just_status: true)
        run_local("#{git_prefix} remote add deployment #{remote_user}@#{ipv4}:#{remote_origin_dir}/")
        run_local("#{git_prefix} push -f deployment master")

        # sync with origin
        run_remote('sudo mkdir -p /var/www')
        run_remote('sudo chown -R deploy:deploy /var/www')
        run_remote("git clone #{remote_origin_dir} #{remote_dir}") unless remote_dir_exists?
        run_remote("cd #{remote_dir}; git fetch")
        run_remote("cd #{remote_dir}; git checkout -- .")
        run_remote("cd #{remote_dir}; git reset --hard origin/master")
      end

      # ---

      def git_prefix
        "GIT_SSH_COMMAND='ssh -i #{Secrets.id_rsa_path}' git"
      end

      def remote_origin_dir
        "/home/#{remote_user}/#{host}.git"
      end

      def remote_dir_exists?
        nofail do
          !!run_remote("cd #{remote_dir}; git rev-parse --is-inside-work-tree")
        end
      end
    end
  end
end
