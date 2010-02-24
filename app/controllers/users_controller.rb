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
    User.transaction do
      @user = User.new(params[:user])
      models = Azimux::AxUser.additional_registration_models
      objects = models.map{|m|instance_eval(&m.load_proc)}

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

      ax_multimodel_transaction objects, :already_in => @user do
        ax_multimodel_if([@user] + objects,
          :if => proc {
            @user.save && models.map do |model|
              instance_eval(&model.save_proc)
            end.all?
          },
          :is_true => proc {
            VerifyMailer.deliver_verify(@user)
          },
          :is_false  => proc {
            render :action => "new"
          }
        )
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
