class AddRetailerIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :retailer_id, :integer
  end

  def self.down
    remove_column :users, :retailer_id
  end
end
