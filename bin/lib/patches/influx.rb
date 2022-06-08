module Patches
  class Influx < Base
    class << self
      def needed?
        return true unless Instance.installed?('influx')
        return true unless Instance.service_running?('influxdb')

        false
      end

      def apply
        Cmd.remote("sudo systemctl stop influxdb", bool: true)
        Cmd.remote("#{yay_prefix} -R influxdb influx-cli", bool: true)
        Cmd.remote("sudo rm -rf /home/deploy/.influxdbv2")
        Cmd.remote("sudo rm -rf /var/lib/influxdb")
        Cmd.remote("sudo rm -rf /var/lib/private/influxdb")
        Cmd.remote("#{yay_prefix} -S influxdb influx-cli")
        Instance.restart_service('influxdb');

        sleep(15)

        3.times do
          Cmd.remote('influx auth list', bool: true) # primes influx or something idk
          sleep(1)
        end

        Cmd.remote('influx setup -f -o telegraf -u telegraf -p telegraf -b telegraf')
      end

      # import "influxdata/influxdb/schema"
      # schema.measurements(bucket: "telegraf")
    end
  end
end
