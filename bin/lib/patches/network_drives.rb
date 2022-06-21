module Patches
  class NetworkDrives < Base
    class << self
      def needed?
        Const.mounts.each do |name, rc|
          return true unless Text.remote_md5_eq?("/etc/systemd/system/mount_#{name}.service", mount_unit(name, rc))
          return true unless Instance.service_running?("mount_#{name}")
        end

        false
      end

      def apply
        Cmd.remote("sudo rm -f /etc/systemd/system/mount_*.service", bool: true)

        Const.mounts.each do |name, rc|
          Text.write_remote("/etc/systemd/system/mount_#{name}.service", mount_unit(name, rc))
          Cmd.remote("sudo systemctl daemon-reload")
          Cmd.remote("sudo mkdir -p /mnt/#{name}")
          Cmd.remote("sudo chmod 775 /mnt/#{name}")
          Cmd.remote("sudo chown #{Instance.username}:#{Instance.username} /mnt/#{name}")
          Instance.restart_service("mount_#{name}")
        end
      end

      # ---

      def mount_unit(name, rc)
        <<~TEXT
          [Unit]
          Description=RClone mount for #{name} at #{rc}
          Wants=network-online-target
          After=network-online-target

          [Service]
          Type=notify
          ExecStart=/usr/bin/rclone mount \\
            --verbose \\
            --allow-other \\
            --umask=0000 \\
            --uid=1000 \\
            --config #{Const.remote_rclone_conf_path} \\
            #{rc} /mnt/#{name}
          ExecStop=/bin/fusermount -uz /mnt/#{name}
          Restart=always

          [Install]
          WantedBy=default.target
        TEXT
      end
    end
  end
end
