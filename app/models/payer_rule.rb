class PayerRule < ActiveRecord::Base
  belongs_to :payer
  has_many :payer_rule_categories
  has_many :categories, :through => :payer_rule_categories
  
  validates_presence_of :payer_id, :billing_by, :billing_phone_number,
  :allowance, :rollover, :approval_phone_number, :pin
end
