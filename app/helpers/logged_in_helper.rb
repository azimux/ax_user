module LoggedInHelper
  def logged_in_as_admin?
    if @ax_user
      @ax_user.in_role?('admin')
    end
  end
end