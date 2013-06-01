class MonetizePurchase < ActiveRecord::Migration
  def change
    add_money :purchases, :price
  end

end
