class AddCategoryToRules < ActiveRecord::Migration
  def change
    add_column :rules, :category, :string
  end
end
