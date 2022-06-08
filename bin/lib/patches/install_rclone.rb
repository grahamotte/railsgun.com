module Patches
  class InstallRclone < Base
    class << self
      def needed?
        Secrets.reload!

        return true unless Instance.installed?('rclone')
        return true unless Text.remote_md5_eq?("/etc/fuse.conf", fuse_conf)
        return true unless Text.eq?(local_config, remote_config)

        false
      end

      def apply
        Secrets.reload!

        Cmd.remote("#{yay_prefix} -S fuse2")
        Text.write_remote("/etc/fuse.conf", fuse_conf)

        Cmd.remote("#{yay_prefix} -S rclone")
        Cmd.remote("mkdir -p #{File.dirname(remote_rclone_conf_path)}")
        Cmd.remote("sudo touch #{remote_rclone_conf_path}")
        Cmd.remote("sudo chown #{Instance.username}:#{Instance.username} #{remote_rclone_conf_path}")
        Text.write_remote(remote_rclone_conf_path, local_config)

        if Secrets.rclone.dig('dropbox').present?
          local_dropbox_token = Secrets.rclone['dropbox']['token']
          remote_dropbox_token = Text.with_local_tmp(remote_config) { |x| ParseConfig.new(x)['dropbox']['token'] }
          if local_dropbox_token || remote_dropbox_token
            newest_token = dropbox_token_expiry(local_dropbox_token) > dropbox_token_expiry(remote_dropbox_token) ? local_dropbox_token : remote_dropbox_token
            Secrets.all['rclone']['dropbox']['token'] = newest_token
            Secrets.save!
            Text.write_remote(remote_rclone_conf_path, Secrets.rclone_config)
          end
        end
      end

      def local_config
        Secrets.rclone_config.to_s
      end

      def remote_config
        Cmd.remote("cat #{remote_rclone_conf_path}")
      rescue StandardError
        ""
      end

      def dropbox_token_expiry(token)
        return Time.at(0) if token.blank?

        JSON.parse(token).dig('expiry').then { |x| Time.parse(x) }
      end

      def fuse_conf
        <<~TEXT
          user_allow_other
        TEXT
      end
    end
  end
end
