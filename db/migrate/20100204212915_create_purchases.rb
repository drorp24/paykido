class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.integer :payer_id
      t.integer :retailer_id
      t.integer :product_id
      t.decimal :amount
      t.date :purchase_date
      t.date :billing_date
      t.integer :billing_by

      t.timestamps
    end
  end

  def self.down
    drop_table :purchases
  end
end
