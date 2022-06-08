module Patches
  class Postgres < Base
    class << self
      def needed?
        return true unless Cmd.remote("psql -l | grep #{Utils.project_name}_production", bool: true)
        return true unless service_running?('postgresql')

        false
      end

      def apply
        Cmd.remote("#{yay_prefix} -S postgresql postgresql-libs")

        if Utils.nofail { Cmd.remote('sudo ls /var/lib/postgres/data/base') } # db exists
          restart_service('postgresql')
        else
          Cmd.remote("sudo -u postgres initdb -E unicode -D /var/lib/postgres/data")
          restart_service('postgresql')
          Cmd.remote("cd ~postgres; sudo -u postgres createuser -s deploy")
          Cmd.remote("cd ~postgres; sudo -u postgres createdb #{Utils.project_name}_production")
        end
      end
    end
  end
end
