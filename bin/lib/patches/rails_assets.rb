module Patches
  class RailsAssets < Base
    class << self
      def apply
        Cmd.remote("cd #{Const.remote_root}; #{Const.asdf_exec} bundle install")
        Cmd.remote("cd #{Const.remote_root}; #{Const.asdf_exec} yarn")
        Cmd.remote("#{Const.rails} rake assets:precompile")
        Cmd.remote("#{Const.rails} rake db:migrate")
      end
    end
  end
end
