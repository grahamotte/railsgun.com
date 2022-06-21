module Patches
  class FullDeploy < Base
    class << self
      def leaf?
        false
      end

      def apply
        Patches::Lint.call
        Patches::MakeKnown.call
        Patches::DeploymentUser.call
        Patches::WritePacmanConfig.call
        Patches::Yay.call
        Patches::SystemUpdate.call
        Patches::Asdf.call
        Patches::AsdfTools.call
        Patches::InstallUtils.call
        Patches::CleanCaches.call
        Patches::Influx.call
        Patches::Telegraf.call
        Patches::Grafana.call
        Patches::DevEnv.call
        Patches::Rclone.call
        Patches::NetworkDrives.call
        Patches::Dns.call
        Patches::Cert.call
        Patches::Nginx.call
        Patches::SyncAllCode.call
        Patches::SyncSecrets.call
        Patches::Postgres.call
        Patches::Redis.call
        Patches::RailsAssets.call
        Patches::Rails.call
        Patches::Swapoff.call
        Config::Patch.call
      end
    end
  end
end
