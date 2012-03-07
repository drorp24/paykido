class AddCategoryToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :category, :string
  end
end
