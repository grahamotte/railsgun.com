module Patches
  class RailsAssets < Base
    class << self
      def apply
        Utils.run_remote("cd #{remote_dir}; #{asdf_exec_prefix} bundle install")
        Utils.run_remote("cd #{remote_dir}; #{asdf_exec_prefix} yarn")
        Utils.run_remote("#{rails_prefix} rake assets:precompile")
        Utils.run_remote("#{rails_prefix} rake db:migrate")
      end
    end
  end
end
