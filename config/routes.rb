Lokusapp::Application.routes.draw do


  resources :devices do
    collection do
      get :new_point
    end

    member do

      get :new_point1
    end

  end

  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  resources :home do


  end


  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'sessions' => 'sessions#create', :as => 'loginpost'
        get 'sessions' => 'sessions#create', :as => 'login'
        delete 'sessions' => 'sessions#destroy', :as => 'logout'
      end

      resources :users do
        collection do
          get :register_user
          post :register_user

        end

        member do

        end
      end



    end
  end

end