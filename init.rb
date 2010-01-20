ActionController::Base.class_eval { include ::Azimux::RequireLoginController }
ActionView::Base.class_eval { include LoggedInHelper }