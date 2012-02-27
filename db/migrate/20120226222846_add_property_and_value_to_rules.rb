class AddPropertyAndValueToRules < ActiveRecord::Migration
  def change
    add_column :rules, :property, :string
    add_column :rules, :value, :string
  end
end
