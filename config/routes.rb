Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :plans, only: [:index, :show, :new, :create, :update] do
    resources :chats, only: :create
  end

  resources :chats, only: :show do
    resources :messages, only: :create

    member do
      post :save_roadmap
    end
  end
end
