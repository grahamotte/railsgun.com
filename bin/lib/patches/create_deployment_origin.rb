module Patches
  class CreateDeploymentOrigin < Base
    class << self
      def needed?
        return false unless Instance.exists?
        return true unless remote_origin_exists?

        false
      end

      def apply
        # make known
        Utils.run_local("ssh-keygen -R #{Instance.ipv4}")
        Utils.run_local("ssh-keyscan -H #{Instance.ipv4} >> ~/.ssh/known_hosts", just_status: true)

        # clear dirs
        Utils.run_local("rm -rf #{local_dir}/tmp/#{Utils.domain_name}.git")
        Utils.run_remote("rm -rf #{remote_origin_dir}")

        # create origin and push current
        Utils.run_remote("#{yay_prefix} -S rsync") unless installed?('rsync')
        Utils.run_local("git clone --bare #{local_dir} #{local_dir}/tmp/#{Utils.domain_name}.git")
        Utils.run_local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{local_dir}/tmp/#{Utils.domain_name}.git/ #{Instance.username}@#{Instance.ipv4}:#{remote_origin_dir}/")

        # cleanup
        Utils.run_local("rm -rf #{local_dir}/tmp/#{Utils.domain_name}.git")
      end

      # ---

      def remote_origin_dir
        "/home/#{Instance.username}/#{Utils.domain_name}.git"
      end

      def remote_origin_exists?
        Utils.run_remote("[ -d #{remote_origin_dir} ]", just_status: true)
      rescue StandardError
        false
      end
    end
  end
end
