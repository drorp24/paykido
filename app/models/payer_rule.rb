class PayerRule < ActiveRecord::Base
  belongs_to :payer
  has_many :payer_rule_categories
  has_many :categories, :through => :payer_rule_categories
  
  validates_presence_of :payer_id, :billing_id
  validates_numericality_of :auto_authorize_under, :greater_than_or_equal_to => 0
  validates_numericality_of :auto_deny_over, :greater_than_or_equal_to => 1
#  validates_length_of :authorization_phone, :is => 10      NO WAY to store zero-leaded strings without being cutoff
  
  validate :amounts_are_sensible
  
  def before_save
    if self.authorization_phone.length < 10
      
    end
  end
  
  def authorization_channel   # a pseudo attribute at that stage - to be added to the model whenever
    @authorization_channel
  end
  
  def authorization_channel=(ac)
    
  end
  
  def edited_budget
    number_to_currency(self.allowance)
  end
  
  def edited_budget=(edited)
    self.allowance = edited.delete "$"
  end
  
  def edited_auto_authorize_under
    number_to_currency(self.auto_authorize_under).strip
  end
  
  def edited_auto_authorize_under=(edited)
    self.auto_authorize_under = edited.delete "$"
  end

  def edited_auto_deny_over
    number_to_currency(self.auto_deny_over)
  end
  
  def edited_auto_deny_over=(edited)
    self.auto_deny_over = edited.delete "$"
  end
  
  def edited_authorization_phone
    number_to_phone(self.authorization_phone, :area_code => true, :country_code => 972)
#    self.authorization_phone.to_s
  end
  
  def edited_authorization_phone=(edited)
#    self.authorization_phone = edited.gsub(/[()-]/, '')
    self.authorization_phone = edited.delete "()-"
#    self.authorization_phone = edited
  end


  def amounts_are_sensible
    errors.add(:auto_authorize_under, "is higher than the other one") if self.auto_authorize_under > self.auto_deny_over
  end
  
end
