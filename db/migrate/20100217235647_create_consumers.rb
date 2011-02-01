class CreateConsumers < ActiveRecord::Migration
  def self.up
    create_table :consumers do |t|
      t.integer :payer_id, :null => false, :options =>
        "CONSTRAINT fk_subscriber_payers REFERENCES payers(id)"
      t.string :billing_phone

      t.timestamps
    end
    add_index :consumers, :billing_phone    
  end

  def self.down
    drop_table :consumers
  end
end
