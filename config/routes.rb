Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  get 'home/index'
  get 'home/new'
  get 'home/create'

  resources :users, only: [:index, :show, :edit, :update, :destroy]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
