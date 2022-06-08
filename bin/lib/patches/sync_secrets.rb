module Patches
  class SyncSecrets < Base
    class << self
      def needed?
        return true unless File.exists?(local_rails_path)
        return true unless Text.eq?(File.read(local_rails_path), Secrets.all_rails_formatted)
        return true unless Text.remote_md5_eq?(remote_rails_path, Secrets.all_rails_formatted)
        return true unless Text.remote_md5_eq?(remote_path, Secrets.all.to_yaml)

        false
      end

      def apply
        Cmd.remote('sudo mkdir -p /var/www')
        Cmd.remote('sudo chown -R deploy:deploy /var/www')
        Cmd.remote("mkdir -p /var/www/#{Utils.domain_name}/config")
        Text.write_remote(remote_rails_path, Secrets.all_rails_formatted)
        Text.write_remote(remote_path, Secrets.all.to_yaml)

        Text.write_local("#{local_rails_path}", Secrets.all_rails_formatted)
      end

      def remote_path
        "/home/#{Instance.username}/.config/secrets/secrets.yml"
      end

      def remote_rails_path
        "#{remote_dir}/config/secrets.yml"
      end

      def local_rails_path
        "#{local_dir}/config/secrets.yml"
      end
    end
  end
end
