class PayerRule < ActiveRecord::Base
  belongs_to :payer
  belongs_to :consumer
  
#  validates_numericality_of :auto_authorize_under, :greater_than_or_equal_to => 0
#  validates_numericality_of :auto_deny_over, :greater_than_or_equal_to => 1
 
#  validate :amounts_are_sensible
  
   
  def rollover_human
    (self.rollover) ?"Off":"On"                                  #reversed for color...
  end
  
  def rollover_human=(rh)
    (rh == "On") ?self.rollover = false :self.rollover = true    #reversed for color...
  end    
  
  def amounts_are_sensible
    errors.add(:auto_authorize_under, "is higher than the other one") if 
      self.auto_authorize_under and self.auto_deny_over and self.auto_authorize_under > self.auto_deny_over
  end
  

end
