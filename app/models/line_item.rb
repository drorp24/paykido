class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  
  attr_reader :order_id
  
  def self.from_cart_item(cart_item)
    li = self.new
    li.product     = cart_item.product
    li.quantity    = cart_item.quantity
    li.total_price = cart_item.price
    li
  end



def sett (order_id)
  @order_id = order_id
end

end