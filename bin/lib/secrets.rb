class Secrets
  class << self
    def method_missing(m)
      all[m.to_s]
    end

    def all
      @all ||= File
        .expand_path("~/.config/secrets/secrets.yml")
        .then { |x| YAML.load_file(x) }
        .dig('production')
    end

    def id_rsa_path
      @id_rsa_path ||= begin
        p = File.join(File.dirname(File.dirname(__dir__)), 'tmp/id_rsa')
        File.open(p, 'w') { |f| f << id_rsa }
        `chmod 600 #{p}`
        p
      end
    end

    def id_rsa_pub
      @id_rsa_pub ||= `ssh-keygen -f #{id_rsa_path} -y`.chomp
    end

    def id_rsa_pub_path
      @id_rsa_pub_path ||= begin
        p = File.join(File.dirname(File.dirname(__dir__)), 'tmp/id_rsa.pub')
        File.open(p, 'w') { |f| f << id_rsa_pub }
        `chmod 600 #{p}`
        p
      end
    end
  end
end
