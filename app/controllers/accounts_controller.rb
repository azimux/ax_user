class AccountsController < ApplicationController
  def signin
    @username = params[:username]

    store_errors = proc do |msg|
      @form ||= OpenStruct.new
      @form.errors ||= ActiveRecord::Errors.new(self)
      @form.errors.add_to_base(msg)
    end

    if !@username.blank? || !params[:password].blank?
      if !(user = User.authenticate(@username, params[:password]))
        msg = "Invalid username or password."
        store_errors.call msg
      else
        #make sure the user has validated.
        if !user.verified?
          msg = "You need to validate your account
              before you can sign in.  Please check your email for instructions."
          store_errors.call msg
        else
          #user successfully signed in
          user.last_login = Time.zone.now
          user.save!

          redirect_to complete_signin(user)
          return
        end
      end
    end
  end

  def signout
    session[:user] = nil
    dest = (respond_to? :home_url) ? home_url : '/'
    dest ||= "/"

    redirect_to(dest)
  end

  protected
  def complete_signin(user)
    session[:user] = user.id
    action = session[:intended_action]
    controller = session[:intended_controller]
    params_local = {}
    if session[:intended_params]
      session[:intended_params].each_pair do |key, val|
        if !params[key]
          if key == '_method'
            params_local['_method'] = val.to_sym
            params_local[:method] = val.to_sym
          else
            params_local[key] = val
          end
        end
      end
    end

    ["path", "params", "controller", "action"
    ].each {|key| session[("intended_" + key).to_sym] = nil}

    if !action || !controller
      return root_url
    end

    params_local.merge({:action => action, :controller => controller})
  end
end