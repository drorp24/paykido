class PayerRule < ActiveRecord::Base
  belongs_to :payer
  has_many :payer_rule_categories
  has_many :categories, :through => :payer_rule_categories
  
  validates_presence_of :payer_id, :billing_id
#  validates_length_of :authorization_phone, :is => 10
  
  validate :amounts_are_sensible
  
  def amounts_are_sensible
    errors.add(:auto_authorize_under, "is higher than the other one") if self.auto_authorize_under > self.auto_deny_over
  end
  
end
