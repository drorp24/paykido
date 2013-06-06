class PurchaseAmountCanBeNull < ActiveRecord::Migration
  def change
    change_column :purchases, :amount, :decimal, :null => true
  end
end
