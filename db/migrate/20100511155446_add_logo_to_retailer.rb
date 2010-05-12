class AddLogoToRetailer < ActiveRecord::Migration
  def self.up
    add_column :retailers, :logo, :string
  end

  def self.down
    remove_column :retailers, :logo
  end
end
