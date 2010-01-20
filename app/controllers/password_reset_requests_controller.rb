class PasswordResetRequestsController < ApplicationController
  def new
    @password_reset_request = PasswordResetRequest.new

    respond_to do |format|
      format.html # new.html.erb
      #      format.xml  { render :xml => @password_reset_request }
    end
  end

  # POST /password_reset_requests
  # POST /password_reset_requests.xml
  def create
    PasswordResetRequest.transaction do
      @password_reset_request = PasswordResetRequest.new(params[:password_reset_request])
      @username_or_email = params[:username_or_email]

      user = User.find_by_email(@username_or_email)
      user ||= User.find_by_username(@username_or_email)

      if !user
        errors.add(:username_or_email, "Could not find a user with that name or email address")
        render :action => :new
        return
      end

      user.password_reset_requests << @password_reset_request

      respond_to do |format|
        if @password_reset_request.save && user.save
          VerifyMailer.deliver_forgot_password(user)

          flash[:notice] = 'Password reset request made, go check your email!'

          format.html { redirect_to(@password_reset_request) }
          #format.xml  { render :xml => @password_reset_request, :status => :created, :location => @password_reset_request }
        else
          format.html { render :action => "new" }
          #format.xml  { render :xml => @password_reset_request.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def show

  end
end
