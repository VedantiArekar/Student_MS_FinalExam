ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Load test/fixtures/*.yml into the test database before each test
    fixtures :all
  end
end
