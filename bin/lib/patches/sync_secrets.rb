module Patches
  class SyncSecrets < Base
    class << self
      def needed?
        return true unless files_same?("#{remote_dir}/config/secrets.yml", File.read(secrets_yml_path))

        false
      end

      def apply
        run_remote('sudo mkdir -p /var/www')
        run_remote('sudo chown -R deploy:deploy /var/www')
        run_remote("mkdir -p /var/www/#{host}/config")
        write_file("#{remote_dir}/config/secrets.yml", File.read(secrets_yml_path))
        run_local("rm -f #{local_dir}/config/secrets.yml")
        run_local("ln -s #{secrets_yml_path} #{local_dir}/config/secrets.yml")
      end
    end
  end
end
