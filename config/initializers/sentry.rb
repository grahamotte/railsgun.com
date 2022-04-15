# frozen_string_literal: true

if Rails.env.production?
  Sentry.init do |config|
    config.dsn = Rails.application.credentials.sentry_dsn
    config.breadcrumbs_logger = [:active_support_logger]
    config.traces_sample_rate = 0
    config.traces_sampler = ->(_) { false }
  end
end
