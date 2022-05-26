class Instance
  attr_accessor :ipv4

  class << self
    #
    # interface
    #

    def ipv4
      @ipv4 ||= Config.instance_class.ipv4
    end

    def show
      Config.instance_class.show
    end

    def create
      Config.instance_class.create
    end

    def destroy
      Config.instance_class.destroy
    end

    #
    # helpers
    #

    def reload
      @ipv4 = nil
    end

    def exists?
      ipv4.present?
    end

    def size
      Config.instance_size
    end

    def region
      Config.instance_region
    end

    def image
      Config.deployment_image
    end

    def username
      Config.instance_username
    end

    def password
      SecureRandom.hex(16)
    end

    def id_rsa
      Secrets.id_rsa
    end

    def id_rsa_pub
      Secrets.id_rsa_pub
    end
  end
end
