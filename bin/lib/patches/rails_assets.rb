module Patches
  class RailsAssets < Base
    class << self
      def apply
        run_remote("cd #{remote_dir}; #{asdf_exec_prefix} bundle install")
        run_remote("#{rails_prefix} rake assets:precompile")
        run_remote("#{rails_prefix} rake db:migrate")
      end
    end
  end
end
