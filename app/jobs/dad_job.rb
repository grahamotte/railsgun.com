class DadJob < ApplicationJob
  schedule '*/30 * * * * *'

  def call
    RestClient
      .get('https://icanhazdadjoke.com/', accept: :json)
      .body
      .then { |x| JSON.parse(x)['joke'] }
      .then { |x| Rails.cache.write('dad_123', x) }

    ActionCable.server.broadcast("dad_123", Rails.cache.read('dad_123'))
  end
end
