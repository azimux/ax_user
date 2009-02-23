raise "Could not find redhillonrails" unless RedHillConsulting
ActionController::Base.send(:include, ::Azimux::RequireLoginController) 
ActionView::Base.class_eval {include(LoggedInHelper)}