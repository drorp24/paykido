class AddLogoToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :logo, :string
  end

  def self.down
    remove_column :products, :logo
  end
end
