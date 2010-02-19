class RenameSubscribers < ActiveRecord::Migration
  def self.up
    rename_table :subscribers, :consumers 
  end

  def self.down
    rename_table :consumers, :subscribers
  end
end
