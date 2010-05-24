class AddLocationToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :location, :string
  end

  def self.down
    remove_column :payers, :location
  end
end
