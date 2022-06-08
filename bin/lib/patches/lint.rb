module Patches
  class Lint < Base
    class << self
      def apply
        Cmd.local('bundle exec rubocop -A')
        Cmd.local('yarn run eslint app/javascript/**/*.js')
        Cmd.local('bundle exec rake db:migrate RAILS_ENV=test')
        Cmd.local('bundle exec annotate --models')
        Cmd.local('bundle exec rake db:migrate RAILS_ENV=test')
        Cmd.local('bundle exec rake test')
        Cmd.local('git update-index --refresh && git diff-index --quiet HEAD --')
      end
    end
  end
end
