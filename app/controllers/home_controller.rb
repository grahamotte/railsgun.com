# frozen_string_literal: true

class HomeController < AuthorizedController
  skip_before_action :authorize, only: :index

  def index; end

  def show
    sidekiq_stats = Sidekiq::Stats.new
    redis_keys = %w[redis_version uptime_in_days connected_clients used_memory_human used_memory_peak_human]
    redis_stats = Sidekiq.redis_info.select { |k, _| redis_keys.include?(k) }
    render json: {
      time: Time.zone.now,
      env: Rails.env,
      user_email: current_user.email,
      user_id: current_user.id,
      user_uid: current_user.uid,
      user_password_digest: current_user.password_digest,
      **ActiveRecord::Base.connection.instance_variable_get(:@config).transform_keys { |k| "db_#{k}" },
      **Rails.cache.redis.connection.transform_keys { |k| "cache_#{k}" },
      **redis_stats.transform_keys { |k| "redis_#{k}" },
      sidekiq_processed: sidekiq_stats.processed,
      sidekiq_failed: sidekiq_stats.failed,
      sidekiq_busy: sidekiq_stats.workers_size,
      sidekiq_processes: sidekiq_stats.processes_size,
    }
  end
end
