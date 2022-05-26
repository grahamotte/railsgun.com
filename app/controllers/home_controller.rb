# frozen_string_literal: true

class HomeController < AuthorizedController
  skip_before_action :authorize, only: :index

  def index; end

  def show
    render json: {
      environment: { time: Time.zone.now, env: Rails.env },
      current_user: { **current_user.attributes, **session.to_h },
      database: ActiveRecord::Base.connection.instance_variable_get(:@config),
      cache: { **Rails.cache.redis.connection, **Sidekiq.redis_info },
      sidekiq: Sidekiq::Stats.new.instance_variable_get(:@stats),
    }
  end
end
