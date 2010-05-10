require 'digest/sha1'

class Retailer < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :purchases
  has_many :products, :through => :purchases
  has_many :payers, :through => :purchases
  
  has_many :items
  has_many :products, :through => :items
  
  has_many :rlists
  has_many :payers, :through => :rlists    # to be used for queries such as "who blacklists me" (not likely)

 
  def rlist(payer_id)
    
    rlist = Rlist.find_or_initialize_by_retailer_id_and_payer_id(self.id, payer_id)
    
  end
  
  def status(payer_id)

    self.rlist(payer_id).status
    
  end
  
  def update(payer_id, status)
    
    self.rlist(payer_id).update_attributes!(:status => status)
    
  end
  
  def is_blacklisted(payer_id)
    
    self.status == "blacklisted" 
    
  end

  def is_whitelisted(payer_id)
    
    self.status == "whitelisted" 
 
  end

  def blacklist(payer_id)
    
    self.update(payer_id, "blacklisted")
    
  end
 
  def whitelist(payer_id)
    
   self.update(payer_id, "whitelisted")
    
  end
 



#  validates_presence_of :user, :name, :email 
#  validates_uniqueness_of :user, :name, :email

  attr_accessor :password_confirmation
#  validates_confirmation_of :password

#  validate :password_non_blank
   
   
  def self.authenticate(user, password)
    retailer = self.find_by_name(user)
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



