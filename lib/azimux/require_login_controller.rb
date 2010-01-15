module Azimux
  module RequireLoginController
    def signed_in?
      session[:user]
    end

    def user
      @user || prep_user_variable
    end

    def prep_user_variable
      if session[:user]
        @user ||= begin
          User.find(session[:user])
        rescue ActiveRecord::RecordNotFound
        end
      else
        @user = nil
      end
      @user
    end

    def in_role? role
      user.in_role?(role)
    end


    def self.included(base)
      base.helper_method :signed_in?, :user, :prep_user_variable,
        :in_role?
      base.before_filter :prep_user_variable

      base.extend ClassMethods
    end

    def redirect_to_permission_denied
      redirect_to permission_denied_url
    end


    def check_authentication
      if !session[:user]
        session[:intended_action] = action_name
        session[:intended_controller] = controller_name
        session[:intended_params] = {}
        session[:intended_params].merge!(params)
        #session[:intended_method] = request.method
        #session[:intended_path] = request.path

        redirect_to :controller => "user", :action => "signin"
      end
    end

    module ClassMethods
      def arrayify_options options
        options[:except] ||= []

        if options[:except] && !options[:except].is_a?(Array)
          options[:except] = [options[:except]]
        end

        options[:except] += [:signin, :signout]

        if options[:only] && !options[:only].is_a?(Array)
          options[:only] = [options[:only]]
        end
      end

      def require_login options = {}
        options[:except] ||= []
        if options[:except].class != Array
          options[:except] = [options[:except]]
        end
        before_filter :check_authentication,
          :except => [:signin, :signout] + options[:except]
      end

      def require_role role, options = {}
        arrayify_options options

        before_filter(options) do |c|
          c.instance_eval do
            if !user
              check_authentication
            elsif !user.in_role?(role)
              redirect_to_permission_denied
            end
          end
        end
      end

      def require_owner options = {}
        arrayify_options options

        before_filter(options) do |c|
          c.instance_eval do
            if !user
              check_authentication
            else
              regex = /Controller$/
              raise "Expecting to be a controller class" unless self.class.name =~ regex
              model = self.class.name.gsub(regex, "").underscore.singularize.classify.constantize.find(params[:id])

              if user.id == model.user_id.to_i
                true
              else
                redirect_to_permission_denied
              end
            end
          end
        end
      end

    end
  end
end
