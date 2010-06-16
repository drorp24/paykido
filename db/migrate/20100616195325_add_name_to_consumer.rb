class AddNameToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :name, :string
  end

  def self.down
    remove_column :consumers, :name
  end
end
