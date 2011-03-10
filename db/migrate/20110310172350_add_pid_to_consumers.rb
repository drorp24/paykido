class AddPidToConsumers < ActiveRecord::Migration
  def self.up
    add_column :consumers, :pid, :integer
  end

  def self.down
    remove_column :consumers, :pid
  end
end
