class Purchase < ActiveRecord::Base
  belongs_to :payer
  belongs_to :retailer
  belongs_to :product
 
  
  validates_presence_of :payer_id, :retailer_id, :product_id, :amount, :date
  validates_numericality_of :amount
end
