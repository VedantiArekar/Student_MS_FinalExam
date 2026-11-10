# Dockerfile - builds the production image of the Student Management System.
# Build:  docker build -t student-ms .

FROM ruby:3.3-slim

# 1. Operating system packages
#    build-essential + libpq-dev : needed to install the "pg" gem (PostgreSQL driver)
#    curl                        : used by the container health check
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

# 2. Settings for production
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test"

WORKDIR /app

# 3. Install the gems first.
#    Docker caches this step, so it only repeats when the Gemfile changes.
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# 4. Copy the application code
COPY . .
RUN chmod +x bin/*

# 5. Run the app as a normal user instead of "root" (safer)
RUN useradd --create-home rails && \
    mkdir -p log tmp && \
    chown -R rails:rails log tmp
USER rails

EXPOSE 3000

# 6. Docker marks the container "healthy" when /up answers with HTTP 200
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

# 7. On start: prepare the database, then run the Puma server
ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
