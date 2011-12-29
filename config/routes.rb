Rails.application.routes.draw do
  resources :roles

  resources :users do
    member do
      get :edit_password
      put :update_password
      get :edit_verification
      put :update_verification
    end
  end

  resources :password_reset_requests

  match "signin", :to => "accounts#signin", :as => "login"
  match "signout", :to => "accounts#signout", :as => "logout"
  match "permission_denied", :to => "accounts#permission_denied"
end