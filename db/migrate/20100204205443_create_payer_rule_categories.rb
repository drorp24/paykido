class CreatePayerRuleCategories < ActiveRecord::Migration
  def self.up
    create_table :payer_rule_categories do |t|
      t.integer :payer_rule_id
      t.integer :category_id
      t.integer :approved

      t.timestamps
    end
  end

  def self.down
    drop_table :payer_rule_categories
  end
end
