class AddLocationToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :location, :string
  end

  def self.down
    remove_column :purchases, :location
  end
end
