class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table  :purchases do |t|
      
      t.integer   :payer_id,     :null => false, :options =>
        "CONSTRAINT fk_purchase_payers REFERENCES payers(id)"
      t.integer   :retailer_id,  :null => false, :options =>
        "CONSTRAINT fk_purchase_retailers REFERENCES retailers(id)"
      t.integer   :product_id,    :null => false, :options =>
        "CONSTRAINT fk_purchase_products REFERENCES products(id)"
        
      t.decimal   :amount,        :null => false
      t.date      :date, :null => false
      
      t.datetime  :authorization_date
      t.string    :authorization_type
      
      t.datetime  :authentication_date
      t.string    :authentication_type
      
      t.date      :billing_date
      t.integer   :billing_type

      t.timestamps
    end
  end

  def self.down
    drop_table :purchases
  end
end
