class AddPhoneToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :phone, :string
  end

  def self.down
    remove_column :payers, :phone
  end
end
