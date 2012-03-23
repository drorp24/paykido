require 'digest/sha1'

class Payer < ActiveRecord::Base
  has_many  :payer_rules
  has_one :most_recent_payer_rule,
    :class_name =>  'PayerRule' ,
    :order =>       'created_at DESC'

  has_many  :purchases
  has_many  :retailers, :through => :purchases
  has_many  :products, :through => :purchases
  has_many  :consumers
  has_many  :users
  has_many :rules
  
  attr_accessor :password_confirmation
  
#  validates_numericality_of :phone, :allow_nil => true
#  validates_length_of :phone, :is => 10, :allow_nil => true
  
  def remember_me
    @remember_me
  end
  
  def remember_me=(rm)
    
  end

  def phone_alert_human
    (self.phone_alert) ?"Off":"On"                                        #reversed for color...
  end
  
  def phone_alert_human=(value)
    if value == "On" then self.phone_alert = false else self.phone_alert = true end   #reversed for color...
  end    
    
  def email_alert_human
    (self.email_alert) ?"Off":"On"                                        #reversed for color...
  end
  
  def email_alert_human=(value)
    if value == "On" then self.email_alert = false else self.email_alert = true end  #reversed for color...
  end    

  def self.phone_alert_frequency
    [["as soon as it happens ","as it occurs"],["once an hour " , "once an hour"],["twice a day ", "twice a day"]]
  end
  
  def self.phone_events
    [["of every purchase" , "any purchase"],["of every buy request", "authorizations"]]            
  end

  def self.email_alert_frequency
    [["twice weekly","twice weekly"], ["once a day" , "once a day"], ["on a weekly basis", "on a weekly basis"],
     ["once a month", "once a month"]]

  end
  
  def self.email_events
    [["all purchases" , "purchases"], ["special activities" , "special activities"],["offers & promotions", "offers and promos"]]            
  end

  def edited_phone
      number_to_phone(self.phone, :area_code => true)
  end
  
  def edited_phone=(edited)
    self.phone = edited.gsub(/[^0-9]/,"")
  end


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
  
  def self.authenticate_by_hp(email, hash)
    payer = self.find_by_email(email)
    return unless payer
    if payer.hashed_password != hash
      payer = nil
    end
    payer
  end
  
  def self.authenticate_by_hashed_password(hash)
    payer = self.find_by_hashed_password(hash)
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

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
end