class DemoJob < ApplicationJob
  schedule '*/30 * * * * *'

  def call
    RestClient
      .get('https://icanhazdadjoke.com/', accept: :json)
      .body
      .then { |x| JSON.parse(x)['joke'] }
      .then { |x| Rails.cache.write('demo_123', x) }

    ActionCable.server.broadcast("demo_123", Rails.cache.read('demo_123'))
  end
end
