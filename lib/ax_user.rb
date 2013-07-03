module AxUser
  class Engine < Rails::Engine
    config.autoload_paths << File.expand_path("..", __FILE__)

    ActiveRecord::Migrator.migrations_paths <<
        File.expand_path(File.join(File.dirname(__FILE__), "..", "db", "migrate"))
    Rails.application.paths['db/migrate'] = ActiveRecord::Migrator.migrations_paths

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