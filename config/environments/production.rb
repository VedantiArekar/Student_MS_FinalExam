require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Load all code at boot (faster and safer in production).
  config.enable_reloading = false
  config.eager_load = true

  # Never show detailed error pages to visitors.
  config.consider_all_requests_local = false

  # Serve the files in the "public" folder (CSS and JavaScript).
  config.public_file_server.enabled = true

  # Write logs to the console (STDOUT) so "docker logs" shows them.
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Do not fill the log with health check requests.
  config.silence_healthcheck_path = "/up"

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false

  # HTTPS redirect is OFF by default so that http://localhost:3000 works in Docker.
  # Set FORCE_SSL=true when the app runs behind an HTTPS proxy / ingress.
  if ENV["FORCE_SSL"] == "true"
    config.assume_ssl = true
    config.force_ssl = true
    config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  end
end
