class AddConsumerIdToPayerRule < ActiveRecord::Migration
  def self.up
    add_column :payer_rules, :consumer_id, :integer, :options =>
        "CONSTRAINT fk_payer_rule_consumers REFERENCES consumers(id)"
  end

  def self.down
    remove_column :payer_rules, :consumer_id
  end
end
