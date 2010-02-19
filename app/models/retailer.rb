require 'digest/sha1'

class Retailer < ActiveRecord::Base
  validates_presence_of :name, :category_id
  
  has_many :purchases
  has_many :products, :through => :purchases
  has_many :retailers_products
  has_many :products, :through => :retailers_products
  has_many :payers, :through => :purchases

  validates_presence_of :username, :name, :email 
  validates_uniqueness_of :username, :name, :email

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  validate :password_non_blank
   
  def self.authenticate(username, password)
    retailer = self.find_by_name(username)
    if retailer
      expected_password = encrypted_password(password, retailer.salt)
      if retailer.hashed_password != expected_password
        retailer = nil
      end
    end
    retailer
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



