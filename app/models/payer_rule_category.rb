class PayerRuleCategory < ActiveRecord::Base
  belongs_to :payer_rule
  belongs_to :category
  
  validates_presence_of :payer_rule_id, :category_id, :approved
end
