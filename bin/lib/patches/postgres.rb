module Patches
  class Postgres < Base
    class << self
      def needed?
        return true unless Cmd.remote("psql -l | grep #{Const.project}_production", bool: true)
        return true unless Instance.service_running?('postgresql')

        false
      end

      def apply
        Cmd.remote("#{Const.yay} -S postgresql postgresql-libs")

        if Utils.nofail { Cmd.remote('sudo ls /var/lib/postgres/data/base') } # db exists
          Instance.restart_service('postgresql')
        else
          Cmd.remote("sudo -u postgres initdb -E unicode -D /var/lib/postgres/data")
          Instance.restart_service('postgresql')
          Cmd.remote("cd ~postgres; sudo -u postgres createuser -s deploy")
          Cmd.remote("cd ~postgres; sudo -u postgres createdb #{Const.project}_production")
        end
      end
    end
  end
end
