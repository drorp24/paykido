require 'digest/sha1'

class Payer < ActiveRecord::Base
  has_one :payer_rule
  has_many :purchases
  has_many :retailers, :through => :purchases
  has_many :products, :through => :purchases
  
  validates_presence_of :name, :email, :pay_type, :username
  validates_uniqueness_of :username, :name

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  validate :password_non_blank
   
  def self.authenticate(name, password)
    payer = self.find_by_name(name)
    if payer
      expected_password = encrypted_password(password, payer.salt)
      if payer.hashed_password != expected_password
        payer = nil
      end
    end
    payer
  end
  
  
# 'password' is a virtual attribute
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Payer.encrypted_password(self.password, self.salt)
  end
  
  

private

  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end

  
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  

end


