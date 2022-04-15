module Patches
  class RailsAssets < Base
    class << self
      def always_needed?
        true
      end

      def apply
        subsection('bundle') do
          run_remote("cd #{remote_dir}; #{asdf_exec} bundle install")
        end

        subsection('precompile assets') do
          run_remote("#{rails_prefix} rake assets:precompile")
        end

        section('migrate database') do
          run_remote("#{rails_prefix} rake db:migrate")
        end
      end
    end
  end
end
