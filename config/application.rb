require_relative "boot"

# Load only the parts of Rails that this project needs:
# the framework core, the database layer (Active Record),
# controllers and views.
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Load the gems listed in the Gemfile
Bundler.require(*Rails.groups)

module StudentManagementSystem
  class Application < Rails::Application
    # Use the default settings of Rails 8.1
    config.load_defaults 8.1
  end
end
