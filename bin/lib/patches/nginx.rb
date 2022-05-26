module Patches
  class Nginx < Base
    class << self
      def apply
        Utils.run_remote("#{yay_prefix} -S nginx") unless installed?(:nginx)
        Utils.run_remote('sudo mkdir -p /var/www')
        Utils.run_remote('sudo chown -R deploy:deploy /var/www')
        write_file("/etc/nginx/nginx.conf", nginx_conf)
        restart_service("nginx", force: true)
      end

      # ---

      def nginx_conf
        <<~TEXT
          worker_processes 1;

          events {
            worker_connections 1024;
          }

          http {
            include mime.types;
            default_type application/octet-stream;
            sendfile on;
            keepalive_timeout 65;
            gzip on;

            server {
              listen 127.0.0.1:80;
              listen [::1]:80;

              location /nginx_status {
                stub_status on;
                access_log off;
                allow 127.0.0.1;
                deny all;
              }
            }

            server {
              listen 80;
              listen [::]:80;
              server_name #{host};
              return 301 https://$server_name$request_uri;
            }

            server {
              server_name #{host};
              listen 443 ssl http2;
              include /etc/letsencrypt/options-ssl-nginx.conf;
              ssl_certificate /etc/letsencrypt/live/#{host}/fullchain.pem;
              ssl_certificate_key /etc/letsencrypt/live/#{host}/privkey.pem;
              ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
              ssl_stapling on;
              ssl_stapling_verify on;

              root #{remote_dir}/public;
              try_files $uri $uri/index.html $uri.html @rails_app;

              location @rails_app {
                proxy_pass http://localhost:3000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Server $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              }

              location /cable {
                proxy_pass http://localhost:3000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade websocket;
                proxy_set_header Connection Upgrade;
              }

              location /assets {
                alias #{remote_dir}/public/assets;
                gzip_static on;
                gzip on;
                expires max;
                add_header Cache-Control public;
              }

              location /packs {
                alias #{remote_dir}/public/packs;
                gzip_static on;
                gzip on;
                expires max;
                add_header Cache-Control public;
              }
            }

            server {
              server_name gf.#{host};
              listen 443 ssl http2;
              include /etc/letsencrypt/options-ssl-nginx.conf;
              ssl_certificate /etc/letsencrypt/live/#{host}/fullchain.pem;
              ssl_certificate_key /etc/letsencrypt/live/#{host}/privkey.pem;
              ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
              ssl_stapling on;
              ssl_stapling_verify on;

              location / {
                proxy_pass http://localhost:4000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Server $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              }
            }

            server {
              server_name pl.#{host};
              listen 443 ssl http2;
              include /etc/letsencrypt/options-ssl-nginx.conf;
              ssl_certificate /etc/letsencrypt/live/#{host}/fullchain.pem;
              ssl_certificate_key /etc/letsencrypt/live/#{host}/privkey.pem;
              ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
              ssl_stapling on;
              ssl_stapling_verify on;

              location / {
                proxy_pass http://localhost:8000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Server $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              }
            }

            server {
              server_name sq.#{host};
              listen 443 ssl http2;
              include /etc/letsencrypt/options-ssl-nginx.conf;
              ssl_certificate /etc/letsencrypt/live/#{host}/fullchain.pem;
              ssl_certificate_key /etc/letsencrypt/live/#{host}/privkey.pem;
              ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
              ssl_stapling on;
              ssl_stapling_verify on;

              rewrite ^/sidekiq(.*)$ $1;
              rewrite ^/(.*)$ /sidekiq/$1;

              location / {
                proxy_pass http://localhost:3000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Server $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              }
            }
          }
        TEXT
      end
    end
  end
end
