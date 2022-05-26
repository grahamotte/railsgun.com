module Patches
  class Influx < Base
    class << self
      def needed?
        return true unless installed?('influx')
        return true unless service_running?('influxdb')

        false
      end

      def apply
        Utils.run_remote("sudo systemctl stop influxdb", just_status: true)
        Utils.run_remote("#{yay_prefix} -R influxdb influx-cli", just_status: true)
        Utils.run_remote("sudo rm -rf /home/deploy/.influxdbv2")
        Utils.run_remote("sudo rm -rf /var/lib/influxdb")
        Utils.run_remote("sudo rm -rf /var/lib/private/influxdb")
        Utils.run_remote("#{yay_prefix} -S influxdb influx-cli")
        restart_service('influxdb');

        sleep(15)

        3.times do
          Utils.run_remote('influx auth list', just_status: true) # primes influx or something idk
          sleep(1)
        end

        Utils.run_remote('influx setup -f -o telegraf -u telegraf -p telegraf -b telegraf')
      end

      # import "influxdata/influxdb/schema"
      # schema.measurements(bucket: "telegraf")
    end
  end
end
