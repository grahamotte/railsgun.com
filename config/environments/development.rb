require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.domain = 'localhost:5000'
  config.action_controller.perform_caching = false
  config.action_mailer.default_url_options = { host: 'localhost:5000' }
  config.action_mailer.delivery_method = :sendgrid_actionmailer
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.sendgrid_actionmailer_settings = { api_key: Rails.application.secrets.sendgrid_token, raise_delivery_errors: true }
  config.active_job.queue_adapter = :sidekiq
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_storage.service = :local
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.assets.debug = true
  config.assets.quiet = true
  config.cache_classes = false
  config.cache_store = :redis_cache_store, { url: 'redis://localhost:6379/1' }
  config.consider_all_requests_local = true
  config.eager_load = true
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.session_store :cache_store, expire_after: 14.days, secure: false

  # r7
  # config.cache_classes = false
  # config.eager_load = false
  # config.consider_all_requests_local = true
  # config.server_timing = true
  # config.active_storage.service = :local
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.perform_caching = false
  # config.active_support.deprecation = :log
  # config.active_support.disallowed_deprecation = :raise
  # config.active_support.disallowed_deprecation_warnings = []
  # config.active_record.migration_error = :page_load
  # config.active_record.verbose_query_logs = true
  # config.assets.quiet = true
end
