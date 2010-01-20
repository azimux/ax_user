# To change this template, choose Tools | Templates
# and open the template in the editor.

module Azimux
  class AxUser
    def self.enable_ssl= boolean
      @enable_ssl = boolean

      if defined?(UsersController)
        if @enable_ssl
          install_ssl_rules
        else
          uninstall_ssl_rules
        end
      end
    end

    def self.protocol(protocol = "http")
      if protocol == "https" && !ssl_enabled?
        "http"
      else
        protocol
      end
    end

    def self.enable_ssl
      @enable_ssl
    end

    def self.ssl_enabled?
      @enable_ssl
    end

    def self.install_ssl_rules
      if !@ax_ssl_installed
        UsersController.class_eval do
          ssl_required :create, :edit, :delete, :show, :new, :index, :update,
            :edit_verification,
            :update_verification,
            :edit_password,
            :update_password
        end
        AccountsController.class_eval do
          ssl_required :create, :edit, :delete, :show, :new, :index, :update,
            :signin,
            :signout
        end
        PasswordResetRequestsController.class_eval do
          ssl_required :create, :edit, :delete, :show, :new, :index, :update
        end
        @ax_ssl_installed = true
      end
    end

    def self.uninstall_ssl_rules
      if @ax_ssl_installed
        UsersController.class_eval do
          ssl_required
        end
        AccountsController.class_eval do
          ssl_required
        end
        PasswordResetRequestsController.class_eval do
          ssl_required
        end
        @ax_ssl_installed = false
      end
    end

    def self.additional_registration_models
      @additional_registration_models ||= []
    end
  end
end
