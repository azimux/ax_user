# To change this template, choose Tools | Templates
# and open the template in the editor.

module Azimux
  class AxUser
    def self.enable_ssl= boolean
      @enable_ssl = boolean

      if defined?(UserController)
        if @enable_ssl
          install_ssl_rules
        else
          uninstall_ssl_rules
        end
      end
    end

    def self.enable_ssl
      @enable_ssl
    end
    def self.ssl_enabled?
      @enable_ssl
    end

    def self.install_ssl_rules
      UserController.class_eval do
        ssl_required :new, :create, :edit, :delete, :show, :index, :update,
          :signup, :register, :complete_signin, :signin, :signout, :verify,
          :password_enter_new, :password_forgot, :password_request_reset_link,
          :password_reset_complete, :password_reset_link_sent
      end
    end

    def self.uninstall_ssl_rules
      UserController.class_eval do
        ssl_required
      end
    end
  end
end
