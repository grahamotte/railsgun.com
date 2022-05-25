class Config
  class << self
    def deployment_username # deploy
    end

    def instance_region # us-west
    end

    def instance_size # g6-nanode-1
    end

    def subdomains # ['www', 'gf', 'sq']
    end

    def job_concurrency # 3
    end

    def mounts # { dbs: Secrets.dbs_bucket } if Secrets.dbs_bucket.present?
    end
  end

  class Patch < Patches::Base
    class << self
      def needed?
        false
      end

      def apply
      end
    end
  end
end
