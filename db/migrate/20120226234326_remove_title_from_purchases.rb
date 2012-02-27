class RemoveTitleFromPurchases < ActiveRecord::Migration
  def up
    remove_column :purchases, :title
  end

  def down
    add_column :purchases, :title, :string
  end
end
