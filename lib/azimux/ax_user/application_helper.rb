module Azimux
  class AxUser
    module ApplicationHelper
      def horizontal_signin_form
        render :partial=> "accounts/signin_hor_form"
      end

      def vertical_signin_form
        render :partial=> "accounts/signin_form"
      end
    end
  end
end