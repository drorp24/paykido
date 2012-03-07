class AddProdtitleToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :product, :string
    add_column :purchases, :title, :string
  end
end
