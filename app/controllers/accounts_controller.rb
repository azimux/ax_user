class AccountsController < ApplicationController
  def signin
    if params[:username] && params[:password]
      if !(user = User.authenticate(params[:username], params[:password]))
        flash.now[:error] = "Invalid username or password."
      else
        #make sure the user has validated.
        if !user.verified?
          flash.now[:error] = "You need to validate your account
              before you can sign in.  Please check your email for instructions."
        else
          #user successfully signed in
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
      return "/"
    end

    params_local.merge({:action => action, :controller => controller})
  end
end