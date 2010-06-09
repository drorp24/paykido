class AddBillingIdToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :billing_id, :integer
  end

  def self.down
    remove_column :payers, :billing_id
  end
end
