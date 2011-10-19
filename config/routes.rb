Rails.application.routes.draw do
  #  map.resources :roles
  #  map.resources :users, :member => {
  #    :edit_password => :get,
  #    :update_password => :put,
  #    :edit_verification => :get,
  #    :update_verification => :put
  #  }
  #  map.resources :password_reset_requests
  #
  #  map.login "signin", :controller => 'accounts', :action => 'signin'
  #  map.logout "signout", :controller => 'accounts', :action => 'signout'
  #  map.permission_denied "permission_denied", :controller => "accounts", :action => "permission_denied"

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