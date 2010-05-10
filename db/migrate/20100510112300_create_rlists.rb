class CreateRlists < ActiveRecord::Migration
  def self.up
    create_table :rlists do |t|
      
      t.integer :payer_id, :null => false, :options =>
        "CONSTRAINT fk_rlist_payers REFERENCES payers(id)"
      t.integer :retailer_id, :null => false, :options =>
        "CONSTRAINT fk_rlist_retailers REFERENCES retailers(id)"
          
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :rlists
  end
end
