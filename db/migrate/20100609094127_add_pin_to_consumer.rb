class AddPinToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :pin, :string
  end

  def self.down
    remove_column :consumers, :pin
  end
end
