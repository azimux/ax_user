class VerifyMailer < ActionMailer::Base
  def verify(user)
    @user = user
    
    mail(
      :to => user.email,
      :subject => "Thank you for registering with #{$site_name}",
      :from => $from_email
    )
  end

  def forgot_password(user)
    @user = user

    mail(
      :to => user.email,
      :subject => "#{$site_name} reset password request",
      :from => $from_email
    )
  end
end
