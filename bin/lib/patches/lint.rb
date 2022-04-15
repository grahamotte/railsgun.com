module Patches
  class Lint < Base
    class << self
      def always_needed?
        true
      end

      def apply
        subsection('linters') do
          run_local('bundle exec rubocop -A')
          run_local('yarn run eslint app/javascript/**/*.js')
        end

        subsection('model annotations') do
          run_local('bundle exec rake db:migrate RAILS_ENV=test')
          run_local('bundle exec annotate --models')
        end

        subsection('model annotations') do
          run_local('bundle exec rake db:drop RAILS_ENV=test')
          run_local('bundle exec rake db:create RAILS_ENV=test')
          run_local('bundle exec rake db:migrate RAILS_ENV=test')
          run_local('bundle exec rake test')
        end
      end
    end
  end
end
