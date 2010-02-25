class CreatePayerRules < ActiveRecord::Migration
  def self.up
    create_table :payer_rules do |t|
      
      t.integer :payer_id, :null => false, :options =>
        "CONSTRAINT fk_payer_rule_payers REFERENCES payers(id)"
      t.integer :billing_id, :null => false, :options =>
        "CONSTRAINT fk_payer_rule_billings REFERENCES billings(id)"
      
      t.decimal :allowance
      t.boolean :rollover

      t.decimal :auto_authorize_under
      t.decimal :auto_deny_over
      
      t.integer :authorization_phone
  

      t.timestamps
    end
  end

  def self.down
    drop_table :payer_rules
  end
end
