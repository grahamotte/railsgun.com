module Patches
  class DeploymentUser < Base
    class << self
      def needed?
        !!Utils.nofail { Utils.run_remote_root('ls -lah') }
      end

      def apply
        # sudo user
        Utils.run_remote_root("useradd #{Instance.username} -m -G wheel")
        Utils.run_remote_root("yes #{Instance.password} | passwd #{Instance.username}")
        Utils.run_remote_root("echo '#{Instance.username} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers")

        # keyfile
        Utils.run_remote_root("cp -r ~/.ssh /home/#{Instance.username}/")
        write_file_root("/home/#{Instance.username}/.ssh/id_rsa", Secrets.id_rsa)
        Utils.run_remote_root("chmod 400 /home/#{Instance.username}/.ssh/id_rsa")
        write_file_root("/home/#{Instance.username}/.ssh/id_rsa.pub", Secrets.id_rsa_pub)
        Utils.run_remote_root("chmod 400 /home/#{Instance.username}/.ssh/id_rsa.pub")
        Utils.run_remote_root("chown -R #{Instance.username}:#{Instance.username} /home/#{Instance.username}/")

        # lockout root user
        write_file_root('/etc/ssh/sshd_config', sshd_conf)
        Utils.run_remote_root('systemctl restart sshd.service')

        # allow loopback requests
        Utils.run_remote("sed -i -e '$a\\' ~/.ssh/authorized_keys")
        Utils.run_remote('cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys')
      end

      # ---

      def Utils.run_remote_root(cmd, *opts, bool: false)
        run(cmd, *opts, user: 'root', host: Instance.ipv4, bool: bool)
      end

      def write_file_root(path, data)
        local_tmp_file = File.expand_path(File.join(local_dir, 'tmp', 'file_to_upload'))
        remote_tmp_file = '/tmp/root_uploaded_file'

        File.open(local_tmp_file, 'w+') { |f| f << data; f << "\n" }
        Utils.run_local("scp -i #{Secrets.id_rsa_path} #{local_tmp_file} root@#{Instance.ipv4}:#{remote_tmp_file}")
        Utils.run_remote_root("cp #{remote_tmp_file} #{path}")
      end

      def sshd_conf
        <<~TEXT
          PermitRootLogin no
          AuthorizedKeysFile .ssh/authorized_keys
          PasswordAuthentication no
          ChallengeResponseAuthentication no
          UsePAM yes
          PrintMotd no
          Subsystem sftp /usr/lib/ssh/sftp-server
        TEXT
      end
    end
  end
end
