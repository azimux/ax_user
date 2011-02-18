ActionController::Base.class_eval do
  include ::Azimux::RequireLoginController
  include Azimux::AxUser::ApplicationHelper
end
ActionView::Base.class_eval do
  include LoggedInHelper
  include Azimux::AxUser::ApplicationHelper
end
#puts "#{File.dirname(__FILE__)}/app/helpers/application_helper.rb"
#require "#{File.dirname(__FILE__)}/app/helpers/application_helper.rb"