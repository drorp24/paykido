class CreatePayerRules < ActiveRecord::Migration
  def self.up
    create_table :payer_rules do |t|
      
      t.integer :payer_id, :options =>
        "CONSTRAINT fk_payer_rule_payers REFERENCES payers(id)"
      
      t.decimal :allowance, :precision => 8, :scale => 2, :default => 0
      t.boolean :rollover

      t.decimal :auto_authorize_under, :precision => 8, :scale => 2, :default => 0
      t.decimal :auto_deny_over, :precision => 8, :scale => 2, :default => 0      
  
      t.timestamps
    end
  end

  def self.down
    drop_table :payer_rules
  end
end
