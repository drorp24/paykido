class AddKindToRules < ActiveRecord::Migration
  def change
    add_column :rules, :kind, :string
  end
end
