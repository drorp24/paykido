#require 'ruby-debug'
class Consumer < ActiveRecord::Base
  
  belongs_to :payer
  has_many :purchases
  
  has_many  :payer_rules
  has_one :most_recent_payer_rule,
    :class_name =>  'PayerRule' ,
    :order =>       'created_at DESC'
    
  validate :amounts_are_sensible
  
  def amounts_are_sensible
    errors[:base] << "amounts cannot overlap" if 
      self.auto_authorize_under and self.auto_deny_over and self.auto_authorize_under > self.auto_deny_over
  end

  def allowance_display
    
  end
  def allowance_display=(value)
    
  end
  
  def auto_deny_over_display
    
  end
  def auto_deny_over_display=(value)
    
  end
  
  def auto_authorize_under_display
    
  end
  def auto_authorize_under_display=(value)
    
  end

  after_initialize :init
  def init
      self.allowance  ||= 0           
      self.allowance_period ||= 'Weekly'
      self.allowance_change_date ||= Time.now
      self.balance_on_acd ||= 0
      self.purchases_since_acd ||= 0
      self.auto_authorize_under ||= 0
      self.auto_deny_over ||= 35
  end

  def allowance_day_of_week
    self.allowance_every
  end
  
  def allowance_day_of_week=(value)
    self.allowance_every = value
  end

  def record_allowance_change
    self.balance_on_acd = self.balance
    self.allowance_change_date = Time.now
    self.purchases_since_acd = 0
  end

  def next_allowance_date
    if self.allowance_period == 'Weekly'
      Time.now.next_week
    elsif self.allowance_period == 'Monthly'
      Time.now.next_month.change(:day => 1)
    else
      nil
    end    
  end
 
  def balance

    return @balance if @balance
    
    self.balance_on_acd        ||= 0
    self.allowance             ||= 0
    self.purchases_since_acd   ||= 0
    self.allowance_change_date ||= self.created_at

    @balance = self.balance_on_acd + self.periods_since_acd *  self.allowance - self.purchases_since_acd
 
  end

  def periods_since_acd
    if allowance_period == 'Weekly'
      (Time.now.strftime("%Y").to_i * 52 + Time.now.strftime("%W").to_i) - (allowance_change_date.strftime("%Y").to_i * 52 + allowance_change_date.strftime("%W").to_i)
    elsif allowance_period == 'Monthly'
      (Time.now.strftime("%Y").to_i * 12 + Time.now.strftime("%m").to_i) - (allowance_change_date.strftime("%Y").to_i * 12 + allowance_change_date.strftime("%m").to_i)
    else
      nil 
    end           
  end
    
  def record(amount)
    self.purchases_since_acd += amount
  end
  
  def create_def_payer_rule!
    @rule = self.def_rule
    @rule.consumer_id = self.id
    @rule.save!
    @rule
  end
  
  def def_rule    
      @def_rule = PayerRule.find_by_payer_id(self.payer_id) if self.payer_id    
      @def_rule ||= PayerRule.new(:allowance => 50, :rollover => false, :auto_authorize_under => 0, :auto_deny_over => 25)      
  end
  
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


  def received_pin
    @received_pin
  end
  
  def received_pin=(val)
    
  end
  
  def self.payer_consumers_the_works(payer_id)

    self.find_all_by_payer_id(payer_id,
               :group =>      ("consumers.id, name, balance, pic, authorized"),
               :select =>     "consumers.id, name, balance, pic, sum(amount) as sum_amount, authorized",
               :joins =>      "LEFT OUTER JOIN purchases on consumers.id = purchases.consumer_id",
               :order =>      "consumers.id, authorized")
  end
  
  def self.old_payer_consumers_the_works(payer_id)

    self.find_all_by_payer_id(payer_id,
               :group => ("consumers.id, name, balance, billing_phone, pin, pic, payer_rules.id, allowance, rollover, auto_authorize_under, auto_deny_over, authorized, consumers.updated_at"),
               :select => "consumers.id, name, balance, billing_phone, pin, pic, payer_rules.id as payer_rule_id, allowance, rollover, auto_authorize_under, auto_deny_over, authorized, sum(amount) as sum_amount",
               :joins => "inner join payer_rules on consumers.id = payer_rules.consumer_id LEFT OUTER JOIN purchases on consumers.id = purchases.consumer_id",
               :order => "consumers.updated_at desc")
    
    
  end
  
  def self.added(id)
    
        self.find(id,
               :select => "consumers.id, name, balance, billing_phone, pin, pic, null as payer_rule_id, 0 as allowance, 'f' as rollover, 0 as auto_authorize_under, 1 as auto_deny_over, 'f' as authorized, 0 as sum_amount")

  end
   
   
end