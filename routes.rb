map.resources :roles
map.resources :users, :member => {
  :edit_password => :get,
  :update_password => :put,
  :edit_verification => :get,
  :update_verification => :put
}

map.resources :password_reset_requests
map.login "signin", :controller => 'accounts', :action => 'signin'
map.logout "signout", :controller => 'accounts', :action => 'signout'
map.permission_denied "permission_denied", :controller => "accounts", :action => "permission_denied"
