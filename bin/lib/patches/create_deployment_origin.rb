module Patches
  class CreateDeploymentOrigin < Base
    class << self
      def needed?
        return false unless instance
        return true unless remote_origin_exists?

        false
      end

      def apply
        # make known
        run_local("ssh-keygen -R #{ipv4}")
        run_local("ssh-keyscan -H #{ipv4} >> ~/.ssh/known_hosts", just_status: true)

        # clear dirs
        run_local("rm -rf #{local_dir}/tmp/#{host}.git")
        run_remote("rm -rf #{remote_origin_dir}")

        # create origin and push current
        run_remote("#{yay_prefix} -S rsync") unless installed?('rsync')
        run_local("git clone --bare #{local_dir} #{local_dir}/tmp/#{host}.git")
        run_local("rsync -av #{local_dir}/tmp/#{host}.git/ #{remote_user}@#{ipv4}:#{remote_origin_dir}/")

        # cleanup
        run_local("rm -rf #{local_dir}/tmp/#{host}.git")
      end

      # ---

      def remote_origin_dir
        "/home/#{remote_user}/#{host}.git"
      end

      def remote_origin_exists?
        run_remote("[ -d #{remote_origin_dir} ]", just_status: true)
      rescue StandardError
        false
      end
    end
  end
end
