class AddConsumerIdToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :consumer_id, :integer
  end

  def self.down
    remove_column :purchases, :consumer_id
  end
end
