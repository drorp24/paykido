require 'digest/sha1'
require 'ruby-debug'

class Payer < ActiveRecord::Base
  has_many  :payer_rules
  has_one :most_recent_payer_rule,
    :class_name =>  'PayerRule' ,
    :order =>       'created_at DESC'
  has_one   :billing, :through => :payer_rules
  has_many  :purchases
  has_many  :retailers, :through => :purchases
  has_many  :products, :through => :purchases
  has_many  :consumers
  
  attr_accessor :password_confirmation
  

#  consider linking purchase to consumers vs. payers

 validates_presence_of :user    
  validates_uniqueness_of :user     
  validate :password_non_blank 
  validates_confirmation_of :password
  validates_numericality_of :phone
  validates_length_of :phone, :is => 10
  

  def edited_balance
    number_to_currency(self.balance)
  end
  
  def edited_balance=(edited)
    self.balance = edited.delete "$"
  end
  
  def edited_phone
      number_to_phone(self.phone, :area_code => true)
  end
  
  def edited_phone=(edited)
    self.phone = edited.gsub(/[^0-9]/,"")
  end

 
#  attr_accessor :exists
#  attr_accessor :balance, :user,:hashed_password
  
#  def initialize
#    super()
#    @balance = 0
#    @user = rand.to_s
#    @hashed_password = rand.to_s
#  end
   
  def self.authenticate(user, password)
    payer = self.find_by_user(user) if user
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