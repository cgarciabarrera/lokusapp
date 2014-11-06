Lokusapp::Application.routes.draw do


  resources :devices do
    collection do
      get :new_point
      get :list_own_devices
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


  resources :faq do

  end

  resources :cart do

  end

  resources :item do

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
      end

      resources :devices do
        collection do
          get :register_device
          post :register_device
          get :new_point_mobile
          post :new_point_mobile
          get :new_point
          post :new_point
          get :list_own_devices
          post :list_own_devices
          get :device_last_points
          post :device_last_points

          get :share_with
          post :share_with

          get :unshare
          post :unshare

        end

      end


    end
  end

end