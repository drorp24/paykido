require 'digest/sha1'                           # remove once Devise is in

class Payer < ActiveRecord::Base

  has_many  :consumers
  has_many  :purchases
  has_many  :rules                              # family-default rules (as opposed to consumer rules)
  
  attr_accessor :password_confirmation          # remove once Devise is in
  
  def purchases_with_info
    Purchase.where("payer_id = ?", self.id).includes(:consumer, :retailer)
  end

  ##############################################
  # remove all the following once Devise is in #
  ##############################################

  def self.authenticate(email, password)
    payer = self.find_by_email(email)
    if payer
      return nil unless payer.salt
      expected_password = encrypted_password(password, payer.salt)
      if payer.hashed_password != expected_password
        payer = nil
      end
    end
    payer
  end
  
  def self.authenticate_by_token(email, hash)     
    payer = self.find_by_email_and_hashed_password(email, hash)
  end
    
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Payer.encrypted_password(self.password, self.salt)
  end
  
  def remember_me       
    @remember_me
  end
  
  def remember_me=(rm)
    
  end

private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
end