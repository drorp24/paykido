class AddTinypicToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :tinypic, :string
  end

  def self.down
    remove_column :consumers, :tinypic
  end
end
