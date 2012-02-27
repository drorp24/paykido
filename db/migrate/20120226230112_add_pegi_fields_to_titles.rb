class AddPegiFieldsToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :pegi_rating, :string
    add_column :titles, :pegi_descriptor, :string
  end
end
