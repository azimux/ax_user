class UsersController < ApplicationController
  require_login :only => [:edit, :update, :destroy]
  before_filter :only => [:edit, :update, :destroy] do |c|
    c.instance_eval do
      unless params[:id] && session[:user] && params[:id].to_i == session[:user].to_i &&
          session[:user].to_i > 0
        redirect_to_permission_denied
      end
    end
  end

  if Azimux::AxUser.ssl_enabled?
    Azimux::AxUser.install_ssl_rules
  end

  def new
    @user = User.new
    Azimux::AxUser.additional_registration_models.each do |model|
      instance_eval(&model.new_proc)
    end
  end

  def create
    password1 = params[:user].delete :password1
    password2 = params[:user].delete :password2

    @user = User.new(params[:user])

    #Make sure the passwords match
    if password1 != password2
      @user.errors.add(:password1, "The passwords you entered did not match.")
      @user.errors.add(:password2, "The passwords you entered did not match.")
      render :action => "new"
      return
    end

    if password1.blank?
      @user.errors.add(:password1, "You must provide a password.")
      @user.errors.add(:password2, "You must verify your password.")
      render :action => "new"
      return
    end

    @user.verified = false
    @user.password = password1

    @user.verify_code = Azimux.generate_verify_code

    models = Azimux::AxUser.additional_registration_models
    objects = models.map{|m|instance_eval(&m.create_init_proc)}

    User.transaction do
      success = @user.save && models.map do |model|
                                instance_eval(&model.create_proc)
                              end.all?

      if success
        VerifyMailer.verify(@user).deliver
      else
        render :action => "new"
        raise ActiveRecord::Rollback
      end
    end
  end

  def edit
    @user = User.find(params[:id])

    Azimux::AxUser.additional_registration_models.each do |model|
      instance_eval(&model.edit_proc)
    end
  end

  def update
    User.transaction do
      @user = User.find(params[:id])

      unless Azimux::AxUser.allow_username_edits
        params[:user].delete(:username)
      end

      if @user.id != user.id
        raise "user #{user.id} trying to change password of user #{@user.id}"
      end

      models = Azimux::AxUser.additional_registration_models
      objects = models.map{|m|instance_eval(&m.update_init_proc)}

      User.transaction do
        success = @user.update_attributes(@user.attributes.merge(params[:user]))

        if success
          success = models.map do |model|
                      instance_eval(&model.update_proc)
                    end.all?
        end

        if success
          flash[:notice] = "Successfully updated your account settings"
          redirect_to edit_user_url(@user)
        else
          render :action => "edit"
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def edit_password
    @user = User.find(params[:id])
  end

  def update_password
    password1 = params[:password1]
    password2 = params[:password2]
    password = params[:password]
    @user = User.find(params[:id])

    if params[:code]
      code = params[:code]

      if !(code.length == Azimux::VERIFY_CODE_LENGTH &&
            @user.password_reset_request &&
            @user.password_reset_request.code == code)
        flash[:notice] = "The reset password code that you used from your email is not valid, try again."
        redirect_to new_password_reset_request_url
        return
      end
    else
      unless User.authenticate(@user.username, password)
        @user.errors.add(:base, "The password you entered doesn't match your current password")
        render :action => "edit_password"
        return
      end
    end

    if password1 != password2
      @user.errors.add(:base, "The passwords you entered did not match.")
      render :action => "edit_password"
      return
    end

    if :password1.blank?
      @user.errors.add(:base, "You must provide a password.")
      render :action => "edit_password"
      return
    end


    User.transaction do
      @user.password = password1
      respond_to do |format|
        if @user.save && @user.password_reset_requests.destroy_all
          flash[:notice] = 'Password was successfully changed.  You may now login'
          format.html { redirect_to login_url }
        else
          raise "Something unexpectedly prevented this user #{@user.username} #{@user.id} from updating their password."
        end
      end
    end
  end

  def edit_verification
    @user = User.find(params[:id])
  end

  def update_verification
    User.transaction do
      @user = User.find(params[:id])

      code = params[:code]

      if code.length == Azimux::VERIFY_CODE_LENGTH && @user.verify_code == code
        @user.verified = true
        @user.verify_code = nil

        if @user.save!
          if Role.find_by_name('admin').users.size == 0
            @user.roles << Role.find_by_name('admin')
            @user.save!
          end

          flash[:notice] = 'Your account is activated.  You may now sign in.'
          redirect_to login_url
        end
      end
    end
  end
end
