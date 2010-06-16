class AddPicToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :pic, :string
  end

  def self.down
    remove_column :consumers, :pic
  end
end
