require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.domain = File.basename(Rails.root)
  config.action_cable.allowed_request_origins = ["https://#{File.basename(Rails.root)}"]
  config.action_controller.perform_caching = true
  config.action_mailer.default_url_options = { host: File.basename(Rails.root) }
  config.action_mailer.delivery_method = :sendgrid_actionmailer
  config.action_mailer.perform_caching = false
  config.action_mailer.sendgrid_actionmailer_settings = { api_key: Rails.application.secrets.sendgrid_token, raise_delivery_errors: true }
  config.active_job.queue_adapter = :sidekiq
  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :local
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.assets.compile = false
  config.cache_classes = true
  config.cache_store = :redis_cache_store, { url: 'redis://localhost:6379/1' }
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  config.log_tags = [:request_id]
  config.public_file_server.enabled = true
  config.session_store :cache_store, expire_after: 14.days

  # r7
  # config.cache_classes = true
  # config.eager_load = true
  # config.consider_all_requests_local       = false
  # config.action_controller.perform_caching = true
  # config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  # config.assets.compile = false
  # config.active_storage.service = :local
  # config.log_level = :info
  # config.log_tags = [ :request_id ]
  # config.action_mailer.perform_caching = false
  # config.i18n.fallbacks = true
  # config.active_support.report_deprecations = false
  # config.log_formatter = ::Logger::Formatter.new
  # config.active_record.dump_schema_after_migration = false
end
