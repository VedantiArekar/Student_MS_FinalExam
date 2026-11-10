Rails.application.routes.draw do
  # Health check for Docker and Kubernetes.
  # Returns HTTP 200 when the application has started without errors.
  get "up" => "rails/health#show", as: :rails_health_check

  # JSON API used by the JavaScript frontend:
  #   GET    /api/students       -> index
  #   GET    /api/students/:id   -> show
  #   POST   /api/students       -> create
  #   PATCH  /api/students/:id   -> update
  #   DELETE /api/students/:id   -> destroy
  namespace :api do
    resources :students, only: %i[index show create update destroy]
  end

  # The dashboard page
  root "home#index"
end
