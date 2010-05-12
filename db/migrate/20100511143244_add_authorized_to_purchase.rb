class AddAuthorizedToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :authorized, :boolean
  end

  def self.down
    remove_column :purchases, :authorized
  end
end
