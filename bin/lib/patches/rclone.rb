module Patches
  class Rclone < Base
    class << self
      def needed?
        return true unless Instance.installed?('rclone')
        return true unless Text.remote_md5_eq?("/etc/fuse.conf", fuse_conf)
        return true unless Text.eq?(local_config, remote_config)

        false
      end

      def apply
        Cmd.remote("#{Const.yay} -S fuse2")
        Text.write_remote("/etc/fuse.conf", fuse_conf)

        Cmd.remote("#{Const.yay} -S rclone")
        Cmd.remote("mkdir -p #{File.dirname(Const.remote_rclone_conf_path)}")
        Cmd.remote("sudo touch #{Const.remote_rclone_conf_path}")
        Cmd.remote("sudo chown #{Instance.username}:#{Instance.username} #{Const.remote_rclone_conf_path}")
        Text.write_remote(Const.remote_rclone_conf_path, local_config)
      end

      def local_config
        Secrets.rclone_config.to_s
      end

      def remote_config
        Cmd.remote("cat #{Const.remote_rclone_conf_path}")
      rescue StandardError
        ""
      end

      def fuse_conf
        <<~TEXT
          user_allow_other
        TEXT
      end
    end
  end
end
