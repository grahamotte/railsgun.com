module Patches
  class SyncSecrets < Base
    class << self
      def needed?
        return true unless File.exists?(local_rails_path)
        return true unless text_same?(File.read(local_rails_path), Secrets.all_rails_formatted)
        return true unless files_same?(remote_rails_path, Secrets.all_rails_formatted)
        return true unless files_same?(remote_path, Secrets.all.to_yaml)

        false
      end

      def apply
        Utils.run_remote('sudo mkdir -p /var/www')
        Utils.run_remote('sudo chown -R deploy:deploy /var/www')
        Utils.run_remote("mkdir -p /var/www/#{Utils.domain_name}/config")
        write_file(remote_rails_path, Secrets.all_rails_formatted)
        write_file(remote_path, Secrets.all.to_yaml)

        write_file_local("#{local_rails_path}", Secrets.all_rails_formatted)
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
