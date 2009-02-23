module LoggedInHelper
  def logged_in_as_admin?
    if @user
      @user.in_role?('admin')
    end
  end
end