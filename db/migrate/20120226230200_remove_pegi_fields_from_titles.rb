class RemovePegiFieldsFromTitles < ActiveRecord::Migration
  def up
    remove_column :titles, :pegi_age_rating_id
    remove_column :titles, :pegi_descriptor_id
  end

  def down
    add_column :titles, :pegi_descriptor_id, :string
    add_column :titles, :pegi_age_rating_id, :string
  end
end
