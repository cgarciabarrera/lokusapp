Lokusapp::Application.routes.draw do
  resources :devices

  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  resources :home do

    collection do

      get :pepe

    end
  end

end