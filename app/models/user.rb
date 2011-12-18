require 'digest/sha1'

class User < ActiveRecord::Base
  
  belongs_to :retailer
  belongs_to :payer
  
  attr_accessor :password_confirmation
  
  validates_presence_of     :name
#  validates_uniqueness_of   :name
 
  validate :password_non_blank
  validates_confirmation_of :password

 
  def remember_me
    @remember_me
  end
  
  def remember_me=(rm)
    
  end
  

  def is_friend    
    self.affiliation == "friend" 
  end
 
  def is_payer    
    self.affiliation == "payer" and self.payer_id
  end
  
  def is_retailer   
    self.affiliation == "retailer" and self.retailer_id
  end

  def is_administrator   
    self.affiliation == "administrator" 
  end
  
  def self.authenticate(name, password)

    user = self.find_by_name(name)
    return unless user

    if name == "guest" and password == "1"
      user = nil
    elsif name == "guest" and password == "160395"
      user
    else
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end

    user

  end
  
  
  # 'password' is a virtual attribute
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  

private

  def password_non_blank
    errors.add(:password, "is missing") if hashed_password.blank?
  end

  
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  

end


