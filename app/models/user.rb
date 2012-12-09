require 'digest/sha2'

class User < ActiveRecord::Base
  has_many :password_reset_requests, :order => 'created_at DESC'
  has_and_belongs_to_many :roles
  before_validation(:clobber_existing_unverified_user, :on => :create)

  to_protect = :url_safe_name, :password_hash, :password_salt, :verified
  to_protect << :username unless Azimux::AxUser.allow_username_edits
  attr_protected to_protect

  validates_uniqueness_of :username
  validates_uniqueness_of :url_safe_name
  validates_presence_of :email, :username, :url_safe_name
  validates_format_of :email, :with => Azimux::EMAIL_REGEX,
    :if => Proc.new {|u| !u.email.blank?}
  validates_format_of :url_safe_name, :with => /[[:lower:]\d_]+/

  def clobber_existing_unverified_user
    other_user = User.find_by_username_and_verified(username, false)

    other_user.destroy if other_user
  end

  # Username can be the user's email.
  # Returns a user if authentication was succesful, nil otherwise
  def self.authenticate(username, password)
    user = User.find(:first, :conditions => ['username = ?', username])
    user ||= User.find(:first, :conditions => ['email = ?', username])

    if user
      if Digest::SHA256.hexdigest(password + user.password_salt) == user.password_hash
        user
      end
    end
  end

  def password=(pass)
    hs = User.make_password_hash_and_salt(pass)
    self.password_salt, self.password_hash = hs.salt, hs.hash
  end

  def self.make_password_hash_and_salt(pass)
    hs = Struct.new(:salt,:hash).new
    hs.salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    hs.hash = Digest::SHA256.hexdigest(pass+hs.salt)
    hs
  end

  def email=(email)
    super(email ? email.strip : email)
  end

  def in_role?(role)
    roles.detect do |r|
      r.in_role?(role)
    end
  end

  def self.url_safe_name username
    username.downcase.gsub(/[\W]/, '_')
  end

  def username= uname
    self.url_safe_name = User.url_safe_name(uname)
    write_attribute(:username, uname)
  end

  def password_reset_request
    password_reset_requests.first
  end

  #dummy methods for providing blank password fields
  def password1
  end
  def password2
  end
end

