class ConvertForgotPasswordCodeToRequest < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      rename_table :forgot_password_codes, :password_reset_requests
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      rename_table :password_reset_requests, :forgot_password_codes
    end
  end
end
