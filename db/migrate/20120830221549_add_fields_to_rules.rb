class AddFieldsToRules < ActiveRecord::Migration
  def change
    add_column :rules, :occasion, :string
    add_column :rules, :donator, :string
  end
end
