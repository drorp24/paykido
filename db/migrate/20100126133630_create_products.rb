class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      
      t.integer :category_id,  :null => false
      t.string :title, :null => false
      t.text :description
      t.string :image_url
      t.decimal :price,
         :precision => 8,:scale => 2, :default => 0 

      t.timestamps
  end
      add_index :products, :title 
end

  def self.down
    drop_table :products
  end
end
