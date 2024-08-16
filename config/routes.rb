Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  

  # Recursos para usuários
  resources :users, only: [:index, :show, :edit, :update, :destroy]

  # Recursos para documentos
  resources :documents, only: [:index, :new, :create, :show]

  # Rota de verificação de saúde
  get 'up', to: 'rails/health#show', as: :rails_health_check

  # Rota para a página inicial de documentos
  get 'documents/home', to: 'documents#home', as: :documents_home
end
