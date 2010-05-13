class AddExpectedPinToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :expected_pin, :string
  end

  def self.down
    remove_column :purchases, :expected_pin
  end
end
