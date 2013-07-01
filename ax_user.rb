module AxUser
  class Engine < Rails::Engine
    config.autoload_paths << File.expand_path("..", __FILE__)

    initializer "ax_user" do
      ActionController::Base.class_eval do
        include ::Azimux::RequireLoginController
        include Azimux::AxUser::ApplicationHelper
      end
      ActionView::Base.class_eval do
        include LoggedInHelper
        include Azimux::AxUser::ApplicationHelper
      end
    end
  end
end