require 'rest-client'
require 'json'
require 'net/ssh'
require 'securerandom'
require 'fileutils'
require 'pry'

#
# PRE-RUN CHECKLIST
#

# register website
#   - donald.ns.cloudflare.com
#   - nola.ns.cloudflare.com
# create linode
# create repo

# DIG:
#   - domain
#   - instance
#   - git

#
# HELPERS
#

def ssh(cmd, user: 'deploy', host: @ipv4 )
  puts "#{user}@#{host} $ #{cmd}"
  puts
  ret_d = ''
  Net::SSH.start(host, user) do |s|
    s.open_channel do |channel|
      channel.exec(cmd) do
        channel.on_data { |_, data| puts data; ret_d << data }
        channel.on_extended_data { |_, _, data| puts data; ret_d << data }
        channel.on_request("exit-status") do |_, data|
          v = data.read_long
          raise "EXIT: #{v}" unless v == 0
        end
      end
    end
    s.loop
  end
  ret_d
end

def cmd(c, log: true)
  puts "localhost $ #{c}\n" if log
  x = `#{c}`
  puts x if log
  x
end

def req(log: true, **params)
  puts "#{params.dig(:method).to_s.upcase} #{params.dig(:url)}" if log

  RestClient::Request
    .execute(**params)
    .body
    .then { |x| JSON.parse(x) }
end

def section(s)
  puts
  puts '#' * (s.length + 4)
  puts "# #{s.upcase}"
  puts '#' * (s.length + 4)
  puts
end

#
# ENV
#

['domain', 'name', 'ipv4'].each { |x| FileUtils.rm(x) if File.exists?(x) }

section 'env'

# creds
gh_user = 'grahamotte'
gh_token = File.read(File.expand_path('~/.config/gh_token')).chomp
cf_email = 'graham.otte@gmail.com'
cf_headers = {
  "X-Auth-Email": 'graham.otte@gmail.com',
  "X-Auth-Key": File.read(File.expand_path('~/.config/cf_key')).chomp,
  accept: :json,
  content_type: :json,
}

# user
user = 'deploy'
puts "user = #{user}"
pass = SecureRandom.hex(16)
puts "pass = #{pass}"

# ruby
ruby_version = File.read('.ruby-version').chomp
puts "ruby version = #{ruby_version}"

# domain
domain = File.basename(File.expand_path('../..', __FILE__))
File.open('domain', 'w+') { |f| f.write(domain) }
puts "domain = #{domain}"

# name
name = domain.split('.').first
File.open('name', 'w+') { |f| f.write(name) }
puts "name = #{name}"

# repo
repo_url = "git@github.com:grahamotte/#{domain}.git"
puts "repo url = #{repo_url}"

# instance
linode_token = File.read(File.expand_path('~/.config/linode')).chomp
instances = req(
  url: 'https://api.linode.com/v4/linode/instances',
  method: :get,
  headers: { Authorization: "Bearer #{linode_token}" },
  log: false,
).dig('data')
instance = instances.find { |i| i.dig('label') == domain }
raise "no instance named #{domain} exists" unless instance
ipv4 = instance.dig('ipv4').first
@ipv4 = ipv4
File.open('ipv4', 'w+') { |f| f.write(ipv4) }
cmd("ssh-keygen -R #{ipv4}", log: false)
puts "ipv4 = #{ipv4}"

#
# THE STUFF
#

section "pushing repo"
cmd("rm -rf .git")
cmd("git init")
cmd("git add -A")
cmd("git commit -m \'init\'")
cmd("git remote add origin #{repo_url}")
cmd("git push -f --set-upstream origin master")

section "deployment user"
ssh("useradd #{user} -m -G wheel", user: 'root')
ssh("yes #{pass} | passwd #{user}", user: 'root')
ssh("cp -r ~/.ssh /home/#{user}/", user: 'root')
ssh("chown -R #{user}:#{user} /home/#{user}/", user: 'root')
ssh("echo '#{user} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers", user: 'root')

section "locking down login to deploy user"
ssh("sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config", user: 'root')
ssh("sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config", user: 'root')
ssh('systemctl restart sshd.service', user: 'root')

section 'ssh access'
ssh('ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa')
RestClient::Request.execute(
  url: repo_url.split(':').last.gsub('.git', '').then { |x| "https://api.github.com/repos/#{x}/keys" },
  method: :post,
  payload: { title: user, key: ssh('cat ~/.ssh/id_rsa.pub')}.to_json,
  headers: { Authorization: "Bearer #{gh_token}", accept: :json, content_type: :json}
).body.then { |x| JSON.parse(x) }

section 'update system packages'
ssh("sudo pacman -Syu --noconfirm")

section 'install yay'
ssh('sudo pacman -S --noconfirm git base-devel')
ssh('git clone https://aur.archlinux.org/yay.git')
ssh('cd ~/yay; yes | makepkg -si')
ssh('rm -rf ~/yay')

section 'install dependencies'
yesyay = '--nodiffmenu --noeditmenu --nouseask --nocleanmenu --noupgrademenu --noconfirm'
ssh("yay -S #{yesyay} rbenv ruby-build yarn curl nginx postgresql python2 certbot certbot-nginx")

section 'setup project root'
ssh('sudo mkdir /var/www')
ssh('sudo chown deploy:deploy /var/www')

section "cloudflare dns"
cf_zone = req(
  url: "https://api.cloudflare.com/client/v4/zones",
  method: :post,
  payload: { name: domain }.to_json,
  headers: cf_headers,
)
req(
  url: "https://api.cloudflare.com/client/v4/zones/#{cf_zone.dig('result', 'id')}/dns_records",
  method: :post,
  payload: { type: 'A', name: domain, content: ipv4, proxied: false, ttl: 1 }.to_json,
  headers: cf_headers,
)

section 'https certs'
ssh("sudo certbot --nginx certonly --non-interactive --agree-tos -m go@goram.app -d #{domain}")

section 'setup postgres db'
ssh("sudo -u postgres initdb -D /var/lib/postgres/data")
ssh('sudo systemctl start postgresql.service')
ssh('sudo systemctl enable postgresql.service')
ssh("sudo -u postgres createuser -s deploy")
ssh("sudo -u postgres createdb #{name}_production")

section 'install ruby'
ssh('mkdir ~/tmp')
ssh("export TMPDIR=~/tmp; rbenv install #{ruby_version}")
ssh('rm -rf ~/tmp')

section 'deploy'
ssh("ps aux | grep -v grep | grep nginx | awk '{ print $2 }' | xargs sudo kill -9")
