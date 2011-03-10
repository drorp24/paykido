class RemovePayerIdFromConsumer < ActiveRecord::Migration
  def self.up
    remove_column :consumers, :payer_id
  end

  def self.down
    add_column :consumers, :payer_id, :integer
  end
end
