module Patches
  class InstallRclone < Base
    class << self
      def needed?
        return true unless installed?('rclone')
        return true unless files_same?("/etc/fuse.conf", fuse_conf)
        return true unless files_same?(remote_rclone_conf_path, File.read(rclone_conf_path))

        false
      end

      def apply
        # installing deps
        run_remote("#{yay_prefix} -S rclone rsync fuse2")

        # writing fuse conf
        write_file("/etc/fuse.conf", fuse_conf)

        # paths
        remote_rc_path = remote_rclone_conf_path
        tmp_rc_path = "#{local_dir}/tmp/rclone_remote.conf"
        local_rc_path = rclone_conf_path
        run_remote("mkdir -p #{File.dirname(remote_rclone_conf_path)}")

        # set permissions
        run_remote("mkdir -p #{File.dirname(remote_rclone_conf_path)}")
        run_remote("sudo touch #{remote_rclone_conf_path}")
        run_remote("sudo chown #{remote_user}:#{remote_user} #{remote_rclone_conf_path}")

        # cache rclone updates
        run_local("touch #{tmp_rc_path}")
        run_local("scp #{remote_user}@#{ipv4}:#{remote_rc_path} #{tmp_rc_path} || true")

        # setup files
        run_local("mkdir -p #{File.dirname(local_rc_path)}")
        run_local("touch #{local_rc_path}")
        run_remote("mkdir -p #{File.dirname(remote_rc_path)}")
        run_remote("touch #{remote_rc_path}")

        # update rclone conf everywhere
        local_rc = ParseConfig.new(local_rc_path)
        remote_rc = ParseConfig.new(tmp_rc_path)
        if local_rc['dropbox']
          local_db_token = JSON.parse(local_rc['dropbox']['token']) rescue { 'expiry' => Time.at(0).iso8601 } # rubocop:disable Style/RescueModifier
          remote_db_token = JSON.parse(remote_rc['dropbox']['token']) rescue { 'expiry' => Time.at(0).iso8601 } # rubocop:disable Style/RescueModifier
          if Time.parse(local_db_token['expiry']) > Time.parse(remote_db_token['expiry'])
            local_rc.add_to_group('dropbox', 'token', local_db_token.to_json)
          else
            local_rc.add_to_group('dropbox', 'token', remote_db_token.to_json)
          end
        end
        f = File.open(local_rc_path, 'w'); local_rc.write(f, false); f.close
        write_file(remote_rc_path, File.read(local_rc_path))
        run_local("rm #{tmp_rc_path}")
      end

      # ---

      def fuse_conf
        <<~TEXT
          user_allow_other
        TEXT
      end
    end
  end
end
