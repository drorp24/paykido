class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      
      t.string    :payer_id, :null => false, :options =>
        "CONSTRAINT fk_subscriber_payers REFERENCES payers(id)"
      t.string    :billing_phone, :null => false
  
      t.timestamps
    end
   add_index :subscribers, :billing_phone    
  end

  def self.down
    drop_table :subscribers
  end
end
