class AccountsController < ApplicationController
  def signin
    username = params[:username]
    password = params[:password]

    if !username.blank? || !password.blank?
      user = User.authenticate(username, password)

      unless user
        add_errors("Invalid username or password.")
      else
        #make sure the user has validated.
        if !user.verified?
          add_errors("You need to validate your account
              before you can sign in.  Please check your email for instructions.")
        else
          #user successfully signed in
          user.last_login = (Time.zone || Time).now
          user.save!

          redirect_to complete_signin(user)
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

    [:intended_action, :intended_params, :intended_controller].each do |key|
      session.delete(key)
    end

    if !action || !controller
      return root_url
    end

    params_local.merge({:action => action, :controller => controller})
  end

  def add_errors message
    require 'ostruct'

    @form        ||= OpenStruct.new
    @form.errors ||= ActiveModel::Errors.new(self)
    @form.errors.add(:base, message)
  end
end