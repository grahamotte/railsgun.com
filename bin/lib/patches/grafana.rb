module Patches
  class Grafana < Base
    class << self
      def needed?
        return true unless installed?('grafana-server')
        return true unless files_same?('/etc/grafana.ini', grafana_conf)
        return true unless files_same?('/etc/grafana/provisioning/datasources/datasource.yaml', grafana_datasources_yaml)
        return true unless files_same?('/etc/grafana/provisioning/dashboards/dashboards.yaml', grafana_dashboards_yaml)
        return true unless service_running?('grafana')

        false
      end

      def apply
        Utils.run_remote("#{yay_prefix} -S grafana")
        Utils.run_remote("sudo rm -rf /var/lib/grafana/grafana.db")
        write_file('/etc/grafana.ini', grafana_conf)
        Utils.run_remote("sudo mkdir -p /etc/grafana/provisioning/datasources")
        write_file('/etc/grafana/provisioning/datasources/datasource.yaml', grafana_datasources_yaml)
        Utils.run_remote("sudo mkdir -p /etc/grafana/provisioning/dashboards")
        write_file('/etc/grafana/provisioning/dashboards/dashboards.yaml', grafana_dashboards_yaml)
        restart_service('grafana')
      end

      # ---

      def grafana_datasources_yaml
        <<~TEXT
          apiVersion: 1

          deleteDatasources:

          datasources:
          - name: telegraf
            type: influxdb
            access: proxy
            url: http://localhost:8086
            isDefault: true
            secureJsonData:
              token: #{influx_token}
            jsonData:
              version: Flux
              organization: telegraf
              defaultBucket: telegraf
              tlsSkipVerify: true

          - name: postgres
            type: postgres
            access: proxy
            url: localhost:5432
            password:
            user: #{Instance.username}
            database: #{Utils.project_name}_production
            basicAuth: false
            isDefault: false
            jsonData:
              sslmode: disable
            version: 1
            editable: true
        TEXT
      end

      def grafana_dashboards_yaml
        <<~TEXT
          apiVersion: 1

          providers:
            - name: Default
              folder: Default
              type: file
              allowUiUpdates: true
              options:
                path: #{remote_dir}/data/dashboards
        TEXT
      end

      def grafana_conf
        <<~TEXT
          [server]
          http_port = 4000

          [paths]
          provisioning = /etc/grafana/provisioning
        TEXT
      end
    end
  end
end
