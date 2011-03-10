class RenamePidToPayerId < ActiveRecord::Migration
  def self.up
    rename_column :consumers, :pid, :payer_id
  end

  def self.down
    rename_column :consumers, :payer_id, :pid 
  end
end
