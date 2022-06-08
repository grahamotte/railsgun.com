class Const
  class << self
    def domain
      File.basename(File.dirname(File.dirname(__dir__)))
    end

    def project
      domain_name.split('.').first
    end

    def local_root
      File.dirname(File.dirname(__dir__))
    end

    def remote_root
      "/var/www/#{domain}"
    end
  end
end
