class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      
      t.string    :retailer_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_retailers REFERENCES retailers(id)"
      t.string    :product_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_products REFERENCES products(id)"
      
        t.timestamps
        add_index :items, [:product_id, :retailer_id], :unique => true
        add_index :items, :retailer_id, :unique => false
    end
  end

  def self.down
    drop_table :items
  end
end
