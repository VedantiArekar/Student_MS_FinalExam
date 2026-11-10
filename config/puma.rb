# Puma is the application server that runs the Rails app.

# Number of threads (each thread can handle one request at a time)
max_threads = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
threads max_threads, max_threads

# Port Puma listens on (default 3000)
port ENV.fetch("PORT", 3000)

# Allow "bin/rails restart" and a pid file when needed
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
