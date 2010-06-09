class AddBalanceToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :balance, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    remove_column :consumers, :balance
  end
end
