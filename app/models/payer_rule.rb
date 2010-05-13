class PayerRule < ActiveRecord::Base
  belongs_to :payer
  has_many :payer_rule_categories
  has_many :categories, :through => :payer_rule_categories
  
  validates_presence_of :payer_id, :billing_id
  validates_numericality_of :auto_authorize_under, :greater_than_or_equal_to => 0
  validates_numericality_of :auto_deny_over, :greater_than_or_equal_to => 1
 
  validate :amounts_are_sensible
  
   
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
  


  def amounts_are_sensible
    errors.add(:auto_authorize_under, "is higher than the other one") if self.auto_authorize_under > self.auto_deny_over
  end
  

end
