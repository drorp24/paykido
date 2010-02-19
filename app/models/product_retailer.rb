class ProductRetailer < ActiveRecord::Base
  belongs_to :retailer
  belongs_to :product

  validates_presence_of :retailer_id, :product_id
end
