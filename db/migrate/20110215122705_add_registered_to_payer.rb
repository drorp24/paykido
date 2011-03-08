class AddRegisteredToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :registered, :boolean
  end

  def self.down
    remove_column :payers, :registered
  end
end
