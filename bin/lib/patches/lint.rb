module Patches
  class Lint < Base
    class << self
      def apply
        run_local('bundle exec rubocop -A')
        run_local('yarn run eslint app/javascript/**/*.js')
        run_local('bundle exec rake db:migrate RAILS_ENV=test')
        run_local('bundle exec annotate --models')
        run_local('bundle exec rake db:migrate RAILS_ENV=test')
        run_local('bundle exec rake test')
        run_local('git update-index --refresh && git diff-index --quiet HEAD --')
      end
    end
  end
end
