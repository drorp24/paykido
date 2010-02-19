class CreateProductsRetailers < ActiveRecord::Migration
  def self.up
    create_table :products_retailers, :id => false do |t|
      
      t.string    :retailer_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_retailers REFERENCES retailers(id)"
      t.string    :product_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_products REFERENCES products(id)"
      
        t.timestamps
        add_index :products_retailers, [:product_id, :retailer_id], :unique => true
        add_index :products_retailers, :retailer_id, :unique => false
    end
  end

  def self.down
    drop_table :products_retailers
  end
end
