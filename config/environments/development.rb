require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reload code on every request, so changes appear without restarting.
  config.enable_reloading = true
  config.eager_load = false

  # Show detailed error pages.
  config.consider_all_requests_local = true

  # Show a helpful page if a migration has not been run yet.
  config.active_record.migration_error = :page_load

  config.active_support.deprecation = :log
end
