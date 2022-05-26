module Patches
  class Telegraf < Base
    class << self
      def needed?
        return true unless installed?('telegraf')
        return true unless files_same?('/etc/telegraf/telegraf.conf', telegraf_conf)
        return true unless service_running?('telegraf')

        false
      end

      def apply
        Utils.run_remote("#{yay_prefix} -S telegraf-bin")
        write_file('/etc/telegraf/telegraf.conf', telegraf_conf)
        restart_service('telegraf')
      end

      # ---

      def telegraf_conf
        <<~TEXT
          [global_tags]

          [agent]
            interval = "10s"
            round_interval = true
            metric_batch_size = 1000
            metric_buffer_limit = 10000
            collection_jitter = "0s"
            flush_interval = "10s"
            flush_jitter = "0s"
            precision = ""
            hostname = ""
            omit_hostname = false

          [[inputs.cpu]]
            percpu = true
            totalcpu = true
            collect_cpu_time = false
            report_active = false

          [[inputs.disk]]
            ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

          [[inputs.diskio]]

          [[inputs.net]]

          [[inputs.kernel]]

          [[inputs.mem]]

          [[inputs.processes]]

          [[inputs.swap]]

          [[inputs.system]]

          [[inputs.redis]]

          [[inputs.nginx]]
            urls = ["http://127.0.0.1/nginx_status"]

          [[inputs.postgresql]]
            address = "host=localhost user=deploy sslmode=disable dbname=#{project}_production"
            max_lifetime = "0s"

          [[outputs.influxdb_v2]]
            urls = ["http://127.0.0.1:8086"]
            token = "#{influx_token}"
            organization = "telegraf"
            bucket = "telegraf"
        TEXT
      end
    end
  end
end
