# frozen_string_literal: true

Sidekiq.configure_server do |config|
  Rails.logger = Sidekiq.logger
  ActiveRecord::Base.logger = Sidekiq.logger
  config.failures_max_count = 5_000
  Sidekiq::Status.configure_server_middleware(config, expiration: 1.day)
  Sidekiq::Status.configure_client_middleware(config, expiration: 1.day)
end
