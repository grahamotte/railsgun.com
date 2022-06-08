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
      Config.instance_image
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

    def installed?(program)
      Cmd.remote("command -v #{program}", bool: true)
    end

    def service_running?(service)
      Utils.nofail do
        stat = Cmd.remote("sudo systemctl | grep #{service}.service")&.downcase
        %w[loaded active running].all? { |x| stat.include?(x) }
      end
    end

    def restart_service(service, force: false)
      return if !force && service_running?(service)

      Cmd.remote("sudo systemctl enable #{service}.service")
      Cmd.remote("sudo systemctl restart #{service}.service")

      raise 'not running' unless service_running?(service)
    rescue StandardError => e
      sleep(5)
      raise 'not running' unless service_running?(service)
    end
  end
end
