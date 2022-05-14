module Patches
  class InstallRclone < Base
    class << self
      def needed?
        Secrets.reload!

        return true unless installed?('rclone')
        return true unless files_same?("/etc/fuse.conf", fuse_conf)
        return true unless configs_same?

        false
      end

      def apply
        Secrets.reload!

        subsection('fuse') do
          run_remote("#{yay_prefix} -S fuse2")
          write_file("/etc/fuse.conf", fuse_conf)
        end

        subsection('rclone') do
          run_remote("#{yay_prefix} -S rclone")
          run_remote("mkdir -p #{File.dirname(remote_rclone_conf_path)}")
          run_remote("sudo touch #{remote_rclone_conf_path}")
          run_remote("sudo chown #{remote_user}:#{remote_user} #{remote_rclone_conf_path}")
          write_file(remote_rclone_conf_path, local_config)
        end

        if Secrets.rclone.dig('dropbox').present?
          subsection('dropbox') do
            local_dropbox_token = Secrets.rclone['dropbox']['token']
            remote_dropbox_token = with_tmp_file(remote_config) { |x| ParseConfig.new(x)['dropbox']['token'] }
            if local_dropbox_token || remote_dropbox_token
              newest_token = dropbox_token_expiry(local_dropbox_token) > dropbox_token_expiry(remote_dropbox_token) ? local_dropbox_token : remote_dropbox_token
              Secrets.all['rclone']['dropbox']['token'] = newest_token
              Secrets.save!
              write_file(remote_rclone_conf_path, Secrets.rclone_config)
            end
          end
        end
      end

      def configs_same?
        local_config.split("\n").select(&:present?) == remote_config.split("\n").select(&:present?)
      end

      def local_config
        Secrets.rclone_config.to_s
      end

      def remote_config
        run_remote("cat #{remote_rclone_conf_path}")
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
