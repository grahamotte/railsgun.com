module Patches
  class MountNetworkDrives < Base
    class << self
      def needed?
        mounts.each do |name, rc|
          return true unless files_same?("/etc/systemd/system/mount_#{name}.service", mount_unit(name, rc))
          return true unless service_running?("mount_#{name}")
        end

        false
      end

      def apply
        Utils.run_remote("sudo rm -f /etc/systemd/system/mount_*.service", just_status: true)

        mounts.each do |name, rc|
          write_file("/etc/systemd/system/mount_#{name}.service", mount_unit(name, rc))
          Utils.run_remote("sudo systemctl daemon-reload")
          Utils.run_remote("sudo mkdir -p /mnt/#{name}")
          Utils.run_remote("sudo chmod 775 /mnt/#{name}")
          Utils.run_remote("sudo chown #{Instance.username}:#{Instance.username} /mnt/#{name}")
          restart_service("mount_#{name}")
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
            --config #{remote_rclone_conf_path} \\
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
