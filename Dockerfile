# Stage 1: Dependencies
FROM ruby:4.0.9-slim AS dependencies

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./
RUN bundle install

# Stage 2: Build
FROM dependencies AS build

COPY . .
RUN chmod +x bin/docker-entrypoint

# Stage 3: Production
FROM ruby:4.0.9-slim AS prod

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libpq5 curl && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test"

WORKDIR /app

COPY --from=dependencies /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

RUN useradd -m rails && \
    mkdir -p log tmp storage && \
    chown -R rails:rails /app

USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/up || exit 1

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
