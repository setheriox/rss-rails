Rails.application.routes.draw do
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  resources :categories
  resources :filters
  resources :articles do
    member do
      patch :toggle_read
      patch :toggle_starred
    end
    collection do
      patch :mark_all_read
    end
  end
  resources :feeds
  resources :dashboard, only: [:index]



  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
