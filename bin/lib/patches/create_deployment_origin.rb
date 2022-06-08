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
        Cmd.local("ssh-keygen -R #{Instance.ipv4}")
        Cmd.local("ssh-keyscan -H #{Instance.ipv4} >> ~/.ssh/known_hosts", bool: true)

        # clear dirs
        Cmd.local("rm -rf #{local_dir}/tmp/#{Utils.domain_name}.git")
        Cmd.remote("rm -rf #{remote_origin_dir}")

        # create origin and push current
        Cmd.remote("#{yay_prefix} -S rsync") unless installed?('rsync')
        Cmd.local("git clone --bare #{local_dir} #{local_dir}/tmp/#{Utils.domain_name}.git")
        Cmd.local("rsync -av -e \"ssh -i #{Secrets.id_rsa_path}\" #{local_dir}/tmp/#{Utils.domain_name}.git/ #{Instance.username}@#{Instance.ipv4}:#{remote_origin_dir}/")

        # cleanup
        Cmd.local("rm -rf #{local_dir}/tmp/#{Utils.domain_name}.git")
      end

      # ---

      def remote_origin_dir
        "/home/#{Instance.username}/#{Utils.domain_name}.git"
      end

      def remote_origin_exists?
        Cmd.remote("[ -d #{remote_origin_dir} ]", bool: true)
      rescue StandardError
        false
      end
    end
  end
end
