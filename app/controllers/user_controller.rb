
class UserController < ApplicationController
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

    respond_to do |format|
      format.html
      #format.xml  { render :xml => @places }
    end

  end

  def signout
    session[:user] = nil
    dest = (respond_to? :home_url) ? home_url : '/'
    dest ||= "/"

    redirect_to(dest)
  end


  def password_request_reset_link
    if params[:form]
      user = User.find(:first, :conditions => ["username = :username OR email = :email", params[:form]])
    end

    if !user
      flash[:error] = "Could not find a user with that name or email address"
      redirect_to :action => :forgot, :form => params[:form]
      return
    end

    User.transaction do
      user.forgot_password_code ||= ForgotPasswordCode.new
      user.forgot_password_code.code = Azimux.generate_verify_code

      if user.forgot_password_code.save!
        VerifyMailer.deliver_forgot_password(user)
      end
    end

    redirect_to :action => :password_reset_link_sent, :id => user.id,
      :forgot_password_code => user.forgot_password_code.code
  end

  def password_forgot

  end

  def password_reset_link_sent

  end

  def password_enter_new
    if !params[:id]
      flash.now[:error] = "This shouldn't happen, no userid submitted"
      return
    end

    user = User.find(params[:id])


    if !(params[:forgot_password_code].length == Azimux::VERIFY_CODE_LENGTH &&
          user && user.forgot_password_code &&
          user.forgot_password_code.code == params[:forgot_password_code])

      redirect_to "/static/permission_denied"
      return
    else
      if !params[:password1] && !params[:password2]
        return
      end

      if params[:password1] != params[:password2]
        flash.now[:error] = "The passwords you entered didn't match"
        return
      end



      #xxx make it check minutes?
      User.transaction do
        user.password = params[:password1]
        user.forgot_password_code.destroy
        if user.save!
          redirect_to :action => :password_reset_complete
        else
          flash.now[:error] = "Something went wrong"
        end
      end


    end
  end

  def password_reset_complete
  end


  def register
    @user = User.new
  end

  def signup
    @user = User.new(params[:user])

    #Make sure the passwords match
    if params[:password1] != params[:password2]
      @user.errors.add(:password1, "The passwords you entered did not match.")
      render :controller => :user, :action => :register #, :user => params[:user]
      return
    end

    if params[:password1].blank?
      @user.errors.add(:password1, "You must provide a password.")
      render :controller => :user, :action => :register #, :user => params[:user]
      return
    end

    @user.verified = false
    @user.password = params[:password1]


    @user.verify_code = Azimux.generate_verify_code

    User.transaction do
      if @user.save
        VerifyMailer.deliver_verify(@user)
      else
        render :action => :register
      end
    end
  end

  def verify
    @user = User.find(params[:id])
    if @user == nil
      raise "No such user."
    end

    if params[:code].length == Azimux::VERIFY_CODE_LENGTH && @user.verify_code = params[:code]
      @user.verified = true
      @user.verify_code = nil
      if @user.save!
        if User.count == 1
          #let's double check
          user_in_db = User.find(:all)
          raise "multiple users but count returned 1" unless user_in_db.size == 1
          user_in_db = user_in_db.first
          raise "wrong user" unless user_in_db.url_safe_name == @user.url_safe_name
          @user.roles << Role.find_by_name('admin')
          @user.save!
        end
        flash[:notice] = 'Your account is activated.  You may now sign in.'
      end
    end
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

    ["path", "params", "controller","action"
    ].each {|key| session[("intended_" + key).to_sym] = nil}

    if !action || !controller
      return "/"
    end

    params_local.merge({:action => action, :controller => controller})
  end
end
