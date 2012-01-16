class AddCategoryToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :category_id, :integer
  end
end
