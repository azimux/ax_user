class UsersController < ApplicationController
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
    @user = User.new(params[:user])

    #Make sure the passwords match
    if params[:password1] != params[:password2]
      @user.errors.add(:password1, "The passwords you entered did not match.")
      render :action => "new"
      return
    end

    if params[:password1].blank?
      @user.errors.add(:password1, "You must provide a password.")
      render :action => "new"
      return
    end

    @user.verified = false
    @user.password = params[:password1]

    @user.verify_code = Azimux.generate_verify_code

    User.transaction do
      if @user.save && Azimux::AxUser.additional_registration_models.map do |model|
          instance_eval(&model.create_proc)
        end.all?
        VerifyMailer.deliver_verify(@user)
      else
        User.connection.rollback_db_transaction
        render :action => "new"
      end
    end
  end

  def edit_password
    @user = User.find(params[:id])
  end

  def update_password
    @user = User.find(params[:id])

    code = params[:code]
    password1 = params[:password1]
    password2 = params[:password2]

    if password1 != password2
      errors.add(:password1, "The passwords you entered did not match.")
      render :action => "edit_password"
      return
    end

    if :password1.blank?
      errors.add(:password1, "You must provide a password.")
      render :action => "edit_password"
      return
    end

    if !(code.length == Azimux::VERIFY_CODE_LENGTH &&
          @user.password_reset_request &&
          @user.password_reset_request.code == code)
      User.transaction do
        @user.password = password1
        respond_to do |format|
          if @user.save && @user.password_reset_requests.destroy_all
            flash[:notice] = 'Password was successfully changed.  You may now login'
            format.html { redirect_to login_url }
          else
            User.connection.rollback_db_transaction
            format.html { render :action => "edit_password" }
          end
        end
      end
    else
      respond_to do |format|
        flash[:error] = "The reset password code that you used from your email is not valid, try again."
        format.html { redirect_to new_password_reset_request }
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
          redirect_to login_url
        end
      end
    end
  end
end
