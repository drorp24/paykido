class RemoveFieldsFromPurchases < ActiveRecord::Migration
  def up
    remove_column :purchases, :product_id
  end

  def down
    add_column :purchases, :product_id, :integer
  end
end
