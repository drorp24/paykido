class AddUserfieldsToPayers < ActiveRecord::Migration
  def change
    add_column :payers, :hashed_password, :string
    add_column :payers, :salt, :string
  end
end
