class AddFacebookToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :facebook, :string
  end

  def self.down
    remove_column :payers, :facebook
  end
end
