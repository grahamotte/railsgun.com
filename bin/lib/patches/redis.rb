module Patches
  class Redis < Base
    class << self
      def needed?
        return true unless installed?('redis-cli')
        return true unless service_running?('redis')

        false
      end

      def apply
        Cmd.remote("#{yay_prefix} -S redis")
        restart_service("redis")
      end
    end
  end
end
