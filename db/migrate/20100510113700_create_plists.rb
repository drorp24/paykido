class CreatePlists < ActiveRecord::Migration
  def self.up
    create_table :plists do |t|
      
      t.integer :payer_id, :null => false, :options =>
        "CONSTRAINT fk_plist_payers REFERENCES payers(id)"
      t.integer :product_id, :null => false, :options =>
        "CONSTRAINT fk_plist_products REFERENCES products(id)"
          
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :plists
  end
end
