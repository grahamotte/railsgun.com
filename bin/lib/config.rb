class Config
  class << self
    def instance_region
    end

    def instance_size
    end

    def subdomains
    end

    def job_concurrency
    end

    def mounts
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
