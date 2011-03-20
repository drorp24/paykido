class Consumer < ActiveRecord::Base
  
  belongs_to :payer
  has_many :purchases
  
  has_many  :payer_rules
  has_one :most_recent_payer_rule,
    :class_name =>  'PayerRule' ,
    :order =>       'created_at DESC'

  
#  attr_accessor :billing_phone, :payer_id
  
#  def initialize (consumer)
#    super()
#    @billing_phone = consumer[:billing_phone]
#  end
  
#  validates_numericality_of :billing_phone, :allow_nil => true
#  validates_length_of :billing_phone, :is => 10, :allow_nil => true
#  validates_format_of :content_type, 
#                      :with => /^image/,
#                      :message => "--- you can only upload pictures"

 
  def facebook_user 
    unless @facebook_user 
      @facebook_user = Mogli::User.find(facebook_id,Mogli::Client.new(facebook_access_token, nil)) 
      @facebook_user.fetch 
    end 
    @facebook_user 
  end 
  
  def uploaded_pic
    self.pic
  end
  
  def uploaded_pic=(picture_field)
    self.pic        = base_part_of(picture_field.original_filename)

  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '')
  end


  def edited_balance
    number_to_currency(self.balance)
  end
  
  def edited_balance=(edited)
    self.balance = edited.delete "$"
  end

  def received_pin
    @received_pin
  end
  
  def received_pin=(val)
    
  end
  
  def self.payer_consumers_the_works(payer_id)

    self.find_all_by_payer_id(payer_id,
               :group => ("consumers.id, name, balance, billing_phone, pin, pic, payer_rules.id, allowance, rollover, auto_authorize_under, auto_deny_over, authorized, consumers.updated_at"),
               :select => "consumers.id, name, balance, billing_phone, pin, pic, payer_rules.id as payer_rule_id, allowance, rollover, auto_authorize_under, auto_deny_over, authorized, sum(amount) as sum_amount",
               :joins => "inner join payer_rules on consumers.id = payer_rules.consumer_id LEFT OUTER JOIN purchases on consumers.id = purchases.consumer_id",
               :order => "consumers.updated_at desc")
    
    
  end
  
  def self.SAVEwho_purchased(payer_id, month)
    
    self.find_all_by_payer_id(payer_id,
               :conditions => ["authorized = ? and strftime('%m', date) = ?", true, month],
               :group => ("consumers.id"),
               :select => "consumers.id, sum(amount) as sum_amount, balance, name, billing_phone, pic",
               :joins => "LEFT OUTER JOIN purchases on consumers.id = purchases.consumer_id")

    
  end
  
  def self.SAVEwho_purchased_or_not(payer_id)
 
        self.find_all_by_payer_id(payer_id,
               :select => "consumers.id, 0 as sum_amount, balance, name, billing_phone, pic")

    
  end
  
  def self.added(id)
    
        self.find(id,
               :select => "consumers.id, name, balance, billing_phone, pin, pic, null as payer_rule_id, 0 as allowance, 'f' as rollover, 0 as auto_authorize_under, 1 as auto_deny_over, 'f' as authorized, 0 as sum_amount")

  end
   
   
end