class AddMerchantToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :merchant_id, :string
    add_column :retailers, :merchant_site_id, :string
  end
end
