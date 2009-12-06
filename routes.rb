map.resources :roles
map.login "user/signin", :controller => 'user', :action => 'signin'
map.permission_denied "user/permission_denied", :controller => "user", :action => "permission_denied"
