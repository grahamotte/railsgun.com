module Patches
  class SyncDeploymentCode < Base
    class << self
      def needed?
        return false unless Instance.exists?
        return true unless remote_dir_exists?
        return true unless remote_src_dir_exists?

        local_head = Cmd.local("git rev-parse HEAD")

        remote_head = Cmd.remote("cd #{remote_dir}; git rev-parse HEAD")
        return true if remote_head != local_head

        remote_src_head = Cmd.remote("cd #{remote_src_dir}; git rev-parse HEAD")
        return true if remote_src_head != local_head

        false
      end

      def apply
        # push to origin
        Cmd.local("#{git_prefix} remote remove deployment", bool: true)
        Cmd.local("#{git_prefix} remote add deployment #{Instance.username}@#{Instance.ipv4}:#{remote_origin_dir}/")
        Cmd.local("#{git_prefix} push -f deployment master")

        # sync with origin www
        Cmd.remote('sudo mkdir -p /var/www')
        Cmd.remote("sudo chown -R #{Instance.username}:#{Instance.username} /var/www")
        Cmd.remote("git clone #{remote_origin_dir} #{remote_dir}") unless remote_dir_exists?
        Cmd.remote("cd #{remote_dir}; git fetch")
        Cmd.remote("cd #{remote_dir}; git checkout -- .")
        Cmd.remote("cd #{remote_dir}; git reset --hard origin/master")

        # sync with origin src
        Cmd.remote("sudo mkdir -p #{remote_src_dir}")
        Cmd.remote("sudo chown -R #{Instance.username}:#{Instance.username} #{remote_src_dir}")
        Cmd.remote("git clone #{remote_origin_dir} #{remote_src_dir}") unless remote_src_dir_exists?
        Cmd.remote("cd #{remote_src_dir}; git fetch")
        Cmd.remote("cd #{remote_src_dir}; git checkout -- .")
        Cmd.remote("cd #{remote_src_dir}; git reset --hard origin/master")
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
          !!Cmd.remote("cd #{remote_dir}; git rev-parse --is-inside-work-tree")
        end
      end

      def remote_src_dir
        "/home/#{Instance.username}/src/#{Utils.domain_name}"
      end

      def remote_src_dir_exists?
        Utils.nofail do
          !!Cmd.remote("cd #{remote_src_dir}; git rev-parse --is-inside-work-tree")
        end
      end
    end
  end
end
