module Patches
  class Postgres < Base
    class << self
      def needed?
        return true unless run_remote("psql -l | grep #{project}_production", just_status: true)
        return true unless service_running?('postgresql')

        false
      end

      def apply
        run_remote("#{yay_prefix} -S postgresql postgresql-libs")

        if Utils.nofail { run_remote('sudo ls /var/lib/postgres/data/base') } # db exists
          restart_service('postgresql')
        else
          run_remote("sudo -u postgres initdb -D /var/lib/postgres/data")
          restart_service('postgresql')
          run_remote("sudo -u postgres createuser -s deploy")
          run_remote("sudo -u postgres createdb #{project}_production")
        end
      end
    end
  end
end
