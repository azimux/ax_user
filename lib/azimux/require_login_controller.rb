module Azimux
  module RequireLoginController
    def signed_in?
      session[:user]
    end

    def signin_path
      url_for :controller => 'user', :action => 'signin'
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
      end
      @user
    end

    def in_role? role
      user.in_role?(role)
    end


    def self.included(base)
      base.helper_method :signed_in?, :signin_path, :user, :prep_user_variable,
        :in_role?
      base.before_filter :prep_user_variable

      def base.require_login options = {}
        options[:except] ||= []
        if options[:except].class != Array
          options[:except] = [options[:except]]
        end
        before_filter :check_authentication,
          :except => [:signin, :signout] + options[:except]
      end

      def base.require_role role, options = {}
        options[:except] ||= []
        if options[:except].class != Array
          options[:except] = [options[:except]]
        end
        before_filter(:except => ([:signin, :signout] + options[:except]),
          :only => options[:only]) do |c|
          c.instance_eval do
            u = c.user

            if !u
              c.check_authentication
            elsif !u.in_role?(role)
              c.redirect_to_permission_denied
            end
          end
        end
      end
    end





    def redirect_to_permission_denied
      redirect_to :controller => "user", :action => "permission_denied"
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
  end
end
