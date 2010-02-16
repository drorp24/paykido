class CreatePayerRuleCategories < ActiveRecord::Migration
  def self.up
    create_table :payer_rule_categories do |t|
      
      t.integer :payer_rule_id, :null => false, :options =>
        "CONSTRAINT fk_payer_rule_category_payer_rules REFERENCES payer_rules(id)"
      t.integer :category_id, :null => false, :options =>
        "CONSTRAINT fk_payer_rule_payers REFERENCES categories(id)"
        
      t.integer :approved

      t.timestamps
    end
  end

  def self.down
    drop_table :payer_rule_categories
  end
end
