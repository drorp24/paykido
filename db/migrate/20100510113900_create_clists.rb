class CreateClists < ActiveRecord::Migration
  def self.up
    create_table :clists do |t|
      
      t.integer :payer_id, :null => false, :options =>
        "CONSTRAINT fk_clist_payers REFERENCES payers(id)"
      t.integer :category_id, :null => false, :options =>
        "CONSTRAINT fk_clist_categories REFERENCES categories(id)"
          
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :clists
  end
end
