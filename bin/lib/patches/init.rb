module Patches
  class Init < Base
    class << self
      def apply
        raise 'no name' if init_name.nil?
        raise 'invalid name' unless init_name.include?('.')
        raise "#{init_dir} already exists" if Dir.exist?(init_dir)

        Utils.run_local("mkdir -p #{init_dir}")
        Utils.run_local("git clone git@github.com:grahamotte/railsgun.com.git #{init_dir}")
        Utils.run_local("cd #{init_dir} && asdf install")
        Utils.run_local("cd #{init_dir} && bundle")
        Utils.run_local("cd #{init_dir} && yarn")
        Utils.run_local("cd #{init_dir} && bundle exec rake db:create")
        Utils.run_local("cd #{init_dir} && prod regenerate")
      end

      # ---

      def init_name
        INIT_NAME
      end

      def init_dir
        local_dir
          .then { |x| File.dirname(x) }
          .then { |x| File.join(x, init_name) }
      end
    end
  end
end
