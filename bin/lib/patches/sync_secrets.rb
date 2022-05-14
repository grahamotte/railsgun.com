module Patches
  class SyncSecrets < Base
    class << self
      def needed?
        return true unless File.exists?(local_rails_path)
        return true unless text_same?(File.read(local_rails_path), Secrets.all_rails_formatted)
        return true unless files_same?(remote_rails_path, Secrets.all_rails_formatted)

        false
      end

      def apply
        run_remote('sudo mkdir -p /var/www')
        run_remote('sudo chown -R deploy:deploy /var/www')
        run_remote("mkdir -p /var/www/#{host}/config")
        write_file(remote_rails_path, Secrets.all_rails_formatted)

        write_file_local("#{local_rails_path}", Secrets.all_rails_formatted)
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
