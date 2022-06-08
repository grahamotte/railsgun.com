module Patches
  class DevEnv < Base
    class << self
      def needed?
        !Text.remote_md5_eq?(zshrc_path, zshrc)
      end

      def apply
        Cmd.remote("#{Const.yay} -S zsh")
        Cmd.remote("rm -rf /home/#{Instance.username}/.oh-my-zsh")
        Cmd.remote("rm -f /home/#{Instance.username}/.zshrc")
        Cmd.remote('sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"')
        Cmd.remote("git clone https://github.com/zsh-users/zsh-autosuggestions /home/#{Instance.username}/.oh-my-zsh/custom/plugins/zsh-autosuggestions")
        Text.write_remote(zshrc_path, zshrc)
      end

      private

      def zshrc_path
        "/home/#{Instance.username}/.zshrc"
      end

      def zshrc
        <<~TEXT

          #
          # oh my zsh
          #

          export ZSH_DISABLE_COMPFIX=true
          export DISABLE_AUTO_UPDATE=true
          export ZSH="$HOME/.oh-my-zsh"
          plugins=( git cp zsh-autosuggestions )
          source $ZSH/oh-my-zsh.sh
          PROMPT='%{$fg[magenta]%}<%(?: : !$? )$HOST $USER ${$(git branch --show-current 2>/dev/null):-!g} %~
          > %{$reset_color%}'

          #
          # exports
          #

          export PATH="./bin:/home/#{Instance.username}/.asdf/shims/:/usr/local/sbin:$PATH"
          export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'

          #
          # asdf
          #

          source /opt/asdf-vm/asdf.sh
          reshim() {
            rm -rf ~/.asdf/shims
            asdf reshim
          }

          #
          # file management
          #

          alias ..="cd .."
          alias ...="cd ../.."
          alias ....="cd ../../.."
          alias .....="cd ../../../.."
          alias ~="cd ~"
          alias -- -="cd -"
          alias l="ls -ahG"
          alias ll="ls -lhaG"
          alias lt="ls -thaG"
          alias llt="ls -lhtaG"
          alias lb="ls -ShaG"
          alias llb="ls -lhSaG"

          #
          # git
          #

          alias grb="git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)'"
          alias s="git status"
          alias g="git"
          alias gl="git lg"
          alias gp="git push"
          alias gpf="git push -f"
          alias gad="git add -A"
          alias gca="git commit --amend"
          gocm() {
            message="$argv"
            git commit -m "$(tr '[:lower:]' '[:upper:]' <<< ${message:0:1})${message:1}"
          }
          alias gcom="gocm"
          alias gcm="gocm"
          cc() {
            master=$(git remote show origin | grep HEAD | awk '{print $NF}')
            git --no-pager log origin/$master..HEAD --pretty=format:"%C(yellow)%h %C(green)%ar %Creset%s%C(blue)%d %Creset" && echo
          }
          grom() {
            master=$(git remote show origin | grep HEAD | awk '{print $NF}')
            git fetch origin $master
            git rebase -i origin/$master
          }

          #
          # ruby / rails / development
          #

          alias rs="rails server"
          alias rc="rails console"
          alias m="bundle exec rake db:migrate"
          alias mt="bundle exec rake db:migrate RAILS_ENV=test"
          alias rubo="bundle exec rubocop -A"
          alias annotate="bundle exec annotate --models"
          alias bms="bundle install && bundle exec rake db:migrate && foreman start"
          alias dev="foreman start"
          alias b="bundle"
          alias be="bundle exec"
          alias ber="bundle exec rake"
          rit() {
            [ -f log/test.log ] && rm -f log/test.log
            bundle exec ruby -I test $argv
          }
          reset-db() {
            bundle exec rake db:drop
            bundle exec rake db:create
            bundle exec rake db:migrate
          }
          reset-test-db() {
            bundle exec rake db:drop RAILS_ENV=test
            bundle exec rake db:create RAILS_ENV=test
            bundle exec rake db:migrate RAILS_ENV=test
          }

          #
          # various
          #

          alias myip="curl http://ipinfo.io/ip || echo 'no service'"
          alias yslow="ps -eo pcpu,pid,user,args | awk 'NR >= 2' | sort -k1 -r | head -10 | cut -c1-$(stty size </dev/tty | cut -d' ' -f2)"
          findp() {
            ps aux | grep -v grep | grep "$argv"
          }
          killp() {
            ps aux | grep -v grep | grep "$argv"
            ps aux | grep -v grep | grep "$argv" | awk '{ print $2 }' | xargs kill -9
          }
          findport() {
            lsof -wni tcp:$argv
          }
          killport() {
            lsof -wni tcp:$argv
            lsof -wni tcp:$argv | awk 'NR >= 2 { print $2 }' | xargs kill -9
          }
          docker-clear-all() {
            docker container stop $(docker container list -q)
            docker system prune --force
            docker rm -v $(docker ps -qa)
            docker rmi $(docker images -q) --force
          }
        TEXT
      end
    end
  end
end
