class AddTitleIdToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :title_id, :integer
  end
end
