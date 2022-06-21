class Secrets
  class << self
    def method_missing(m)
      all[m.to_s]
    end

    def path
      File.expand_path("~/.config/secrets/secrets.yml")
    end

    def all
      @all ||= YAML.load_file(path)
    end

    def all_rails_formatted
      { "production" => all, "development" => all }.to_yaml
    end

    def rclone_config
      return if rclone.blank?

      rclone.map do |k1, v1|
        <<~TEXT
          [#{k1}]
          #{v1.map { |k2, v2| "#{k2} = #{v2}" }.join("\n")}
        TEXT
      end.join("\n")
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
