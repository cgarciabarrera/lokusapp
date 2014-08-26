Lokusapp::Application.routes.draw do
  resources :devices do
    collection do

    end

    member do
      get :new_point
    end

  end

  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  resources :home do

    collection do

      get :pepe

    end
  end

end