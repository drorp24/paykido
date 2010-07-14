class AddSkypeToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :skype, :string
  end

  def self.down
    remove_column :payers, :skype
  end
end
