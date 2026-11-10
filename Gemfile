source "https://rubygems.org"

# Ruby 4.0.x
ruby "~> 4.0.0"

# Web framework (8.1.4 or a newer 8.1.x patch release, e.g. 8.1.4.1)
gem "rails", "~> 8.1.4"

# PostgreSQL database driver
gem "pg", "~> 1.5"

# Application server
gem "puma", ">= 6.4"

# Time zone data (only needed on Windows)
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  # Loads the variables from the ".env" file (DB_HOST, DB_USER, ...) automatically
  gem "dotenv-rails"
end
