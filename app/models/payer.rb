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
  has_many  :users
  
  attr_accessor :password_confirmation
  
  validates_numericality_of :phone, :allow_nil => true
  validates_length_of :phone, :is => 10, :allow_nil => true
  
    
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
   
end