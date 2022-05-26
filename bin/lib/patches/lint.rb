module Patches
  class Lint < Base
    class << self
      def apply
        Utils.run_local('bundle exec rubocop -A')
        Utils.run_local('yarn run eslint app/javascript/**/*.js')
        Utils.run_local('bundle exec rake db:migrate RAILS_ENV=test')
        Utils.run_local('bundle exec annotate --models')
        Utils.run_local('bundle exec rake db:migrate RAILS_ENV=test')
        Utils.run_local('bundle exec rake test')
        Utils.run_local('git update-index --refresh && git diff-index --quiet HEAD --')
      end
    end
  end
end
