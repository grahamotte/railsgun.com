module Patches
  class SyncDeploymentCode < Base
    class << self
      def needed?
        return false unless Instance.exists?
        return true unless remote_dir_exists?
        return true unless remote_src_dir_exists?

        local_head = Utils.run_local("git rev-parse HEAD")

        remote_head = Utils.run_remote("cd #{remote_dir}; git rev-parse HEAD")
        return true if remote_head != local_head

        remote_src_head = Utils.run_remote("cd #{remote_src_dir}; git rev-parse HEAD")
        return true if remote_src_head != local_head

        false
      end

      def apply
        # push to origin
        Utils.run_local("#{git_prefix} remote remove deployment", bool: true)
        Utils.run_local("#{git_prefix} remote add deployment #{Instance.username}@#{Instance.ipv4}:#{remote_origin_dir}/")
        Utils.run_local("#{git_prefix} push -f deployment master")

        # sync with origin www
        Utils.run_remote('sudo mkdir -p /var/www')
        Utils.run_remote("sudo chown -R #{Instance.username}:#{Instance.username} /var/www")
        Utils.run_remote("git clone #{remote_origin_dir} #{remote_dir}") unless remote_dir_exists?
        Utils.run_remote("cd #{remote_dir}; git fetch")
        Utils.run_remote("cd #{remote_dir}; git checkout -- .")
        Utils.run_remote("cd #{remote_dir}; git reset --hard origin/master")

        # sync with origin src
        Utils.run_remote("sudo mkdir -p #{remote_src_dir}")
        Utils.run_remote("sudo chown -R #{Instance.username}:#{Instance.username} #{remote_src_dir}")
        Utils.run_remote("git clone #{remote_origin_dir} #{remote_src_dir}") unless remote_src_dir_exists?
        Utils.run_remote("cd #{remote_src_dir}; git fetch")
        Utils.run_remote("cd #{remote_src_dir}; git checkout -- .")
        Utils.run_remote("cd #{remote_src_dir}; git reset --hard origin/master")
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

      def remote_src_dir
        "/home/#{Instance.username}/src/#{Utils.domain_name}"
      end

      def remote_src_dir_exists?
        Utils.nofail do
          !!Utils.run_remote("cd #{remote_src_dir}; git rev-parse --is-inside-work-tree")
        end
      end
    end
  end
end
