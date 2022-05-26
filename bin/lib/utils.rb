class Utils
  class << self
    def req(**params)
      puts "#{params.dig(:method).to_s.upcase} #{params.dig(:url)} #{params.dig(:payload)}".green

      RestClient::Request
        .execute(**params)
        .body
        .then { |x| JSON.parse(x, symbolize_names: true) }
    rescue StandardError => e
      pp e&.http_body
      raise e
    end
  end
end
