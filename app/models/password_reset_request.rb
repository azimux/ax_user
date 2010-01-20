class PasswordResetRequest < ActiveRecord::Base
  belongs_to :user

  def change_code
    self.code = Azimux.generate_verify_code
  end
  
  def initialize hash = nil
    super hash
    self.code ||= Azimux.generate_verify_code
  end
end
