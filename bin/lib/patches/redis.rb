module Patches
  class Redis < Base
    class << self
      def needed?
        return true unless Instance.installed?('redis-cli')
        return true unless Instance.service_running?('redis')

        false
      end

      def apply
        Cmd.remote("#{yay_prefix} -S redis")
        Instance.restart_service("redis")
      end
    end
  end
end
