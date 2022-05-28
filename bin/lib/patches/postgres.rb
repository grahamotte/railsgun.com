module Patches
  class Postgres < Base
    class << self
      def needed?
        return true unless Utils.run_remote("psql -l | grep #{Utils.project_name}_production", bool: true)
        return true unless service_running?('postgresql')

        false
      end

      def apply
        Utils.run_remote("#{yay_prefix} -S postgresql postgresql-libs")

        if Utils.nofail { Utils.run_remote('sudo ls /var/lib/postgres/data/base') } # db exists
          restart_service('postgresql')
        else
          Utils.run_remote("sudo -u postgres initdb -D /var/lib/postgres/data")
          restart_service('postgresql')
          Utils.run_remote("sudo -u postgres createuser -s deploy")
          Utils.run_remote("sudo -u postgres createdb #{Utils.project_name}_production")
        end
      end
    end
  end
end
