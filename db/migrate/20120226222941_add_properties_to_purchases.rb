class AddPropertiesToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :properties, :string
  end
end
