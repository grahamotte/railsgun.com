module Patches
  class RailsAssets < Base
    class << self
      def apply
        Cmd.remote("cd #{Const.remote_root}; #{asdf_exec_prefix} bundle install")
        Cmd.remote("cd #{Const.remote_root}; #{asdf_exec_prefix} yarn")
        Cmd.remote("#{rails_prefix} rake assets:precompile")
        Cmd.remote("#{rails_prefix} rake db:migrate")
      end
    end
  end
end
