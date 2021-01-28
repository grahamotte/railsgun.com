# vars
set :application, File.read('name').chomp
set :name, File.read('name').chomp
set :domain, File.read('domain').chomp
set :puma_bind, "tcp://0.0.0.0:3000"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_prefix, "/usr/bin/rbenv exec"
set :rbenv_ruby, File.read('.ruby-version').chomp
set :repo_url, `git remote get-url origin`.chomp
set :server, File.read('ipv4').chomp
set :user, 'deploy'

# shared
append(:linked_files, "config/master.key")
append(
  :linked_dirs,
  'log', # keep logs
  'public', # keep everything in public so we don't keep recompiling it
  'node_modules', # caches for yarn so it doesn't take forever
  '.bundle', 'bundle', # caches for bundler
  'tmp/sockets', 'tmp/pids', 'tmp/cache', # so we can attach to running processes
)

# prod server
server(fetch(:server), roles: [:web, :app, :db], primary: true, user: fetch(:user))

#
# TASKS
#

namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end
end

before 'puma:restart', 'chown_files' do
  on roles(:app) do
    execute "sudo mkdir -p /var/www/#{fetch(:application)}/shared/log/"
    execute "sudo touch /var/www/#{fetch(:application)}/shared/log/puma_access.log"
    execute "sudo touch /var/www/#{fetch(:application)}/shared/log/puma_error.log"
    execute "sudo chown -R #{fetch(:user)}:#{fetch(:user)} /var/www"
  end
end

before 'puma:restart', 'puma:refresh_config' do
  invoke 'puma:config'
  invoke 'puma:systemd:config'
end

after 'puma:restart', 'restart_nginx' do
  on roles(:app) do
    File
      .read('nginx.conf')
      .gsub('{{domain}}', fetch(:domain))
      .gsub('{{name}}', fetch(:name))
      .then { |x| File.open('tmp/nginx.conf', 'w+') { |f| f.write(x) } }
    upload! 'tmp/nginx.conf', "#{current_path}/nginx.conf"
    execute "sudo cp /var/www/#{fetch(:application)}/current/nginx.conf /etc/nginx/nginx.conf"
    execute "sudo systemctl enable nginx.service"
    execute "sudo systemctl restart nginx.service"
  end
end
