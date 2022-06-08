module Patches
  class Grafana < Base
    class << self
      def needed?
        return true unless Instance.installed?('grafana-server')
        return true unless Text.remote_md5_eq?('/etc/grafana.ini', grafana_conf)
        return true unless Text.remote_md5_eq?('/etc/grafana/provisioning/datasources/datasource.yaml', grafana_datasources_yaml)
        return true unless Text.remote_md5_eq?('/etc/grafana/provisioning/dashboards/dashboards.yaml', grafana_dashboards_yaml)
        return true unless Instance.service_running?('grafana')

        false
      end

      def apply
        Cmd.remote("#{yay_prefix} -S grafana")
        Cmd.remote("sudo rm -rf /var/lib/grafana/grafana.db")
        Text.write_remote('/etc/grafana.ini', grafana_conf)
        Cmd.remote("sudo mkdir -p /etc/grafana/provisioning/datasources")
        Text.write_remote('/etc/grafana/provisioning/datasources/datasource.yaml', grafana_datasources_yaml)
        Cmd.remote("sudo mkdir -p /etc/grafana/provisioning/dashboards")
        Text.write_remote('/etc/grafana/provisioning/dashboards/dashboards.yaml', grafana_dashboards_yaml)
        Instance.restart_service('grafana')
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
            database: #{Const.project}_production
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
                path: #{Const.remote_root}/data/dashboards
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
