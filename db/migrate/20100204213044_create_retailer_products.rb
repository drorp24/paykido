class CreateRetailerProducts < ActiveRecord::Migration
  def self.up
    create_table :retailer_products do |t|
      
      t.string    :retailer_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_retailers REFERENCES retailers(id)"
      t.string    :product_id, :null => false, :options =>
        "CONSTRAINT fk_retailer_product_products REFERENCES products(id)"
      
        t.timestamps
    end
  end

  def self.down
    drop_table :retailer_products
  end
end
