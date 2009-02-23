
class ForgotPasswordCode < ActiveRecord::Base
  belongs_to :user
   
  def change_code
    self.code = Azimux.generate_verify_code
  end
  
  def initialize
    super
    self.code = Azimux.generate_verify_code
  end
end
