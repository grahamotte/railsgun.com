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
        Patches::InstallYay.call
        Patches::SystemUpdate.call
        Patches::InstallAsdf.call
        Patches::InstallAsdfTools.call
        Patches::InstallCurl.call
        Patches::InstallHtop.call
        Patches::CleanCaches.call
        Patches::Influx.call
        Patches::Telegraf.call
        Patches::Grafana.call
        Patches::InstallRclone.call
        Patches::MountNetworkDrives.call
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
