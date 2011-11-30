class VerifyMailer < ActionMailer::Base
  def verify(user)
    @subject    = "Thank you for registering with #{$site_name}"
    @user       = user
    @recipients = user.email
    @from       = $from_email_string
    @sent_on    = Time.now
  end

  def forgot_password(user)
    @subject    = "#{$site_name} password request"
    @user       = user
    @recipients = user.email
    @from       = $from_email_string
    @sent_on    = Time.now
  end
end
