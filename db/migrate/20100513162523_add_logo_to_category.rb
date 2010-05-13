class AddLogoToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :logo, :string
  end

  def self.down
    remove_column :categories, :logo
  end
end
