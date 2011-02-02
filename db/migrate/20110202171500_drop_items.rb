class DropItems < ActiveRecord::Migration
  def self.up
 
        drop_table :items
 
  end

  def self.down
   create_table :items do |t|
      
      t.integer    :retailer_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_retailers REFERENCES retailers(id)"
      t.integer    :product_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_products REFERENCES products(id)"
      
        t.timestamps
        end
        add_index :items, [:product_id, :retailer_id], :unique => true
        add_index :items, :retailer_id, :unique => false

  end
end
