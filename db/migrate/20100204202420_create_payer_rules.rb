class CreatePayerRules < ActiveRecord::Migration
  def self.up
    create_table :payer_rules do |t|
      t.integer :payer_id
      t.integer :billing_by
      t.integer :billing_phone_number
      t.decimal :allowance
      t.boolean :rollover
      t.integer :approval_phone_number
      t.integer :pin
      t.decimal :auto_approve_under
      t.decimal :auto_reject_over

      t.timestamps
    end
  end

  def self.down
    drop_table :payer_rules
  end
end
