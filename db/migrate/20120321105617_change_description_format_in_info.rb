class ChangeDescriptionFormatInInfo < ActiveRecord::Migration
  def up
    change_column :infos, :description, :text
  end

  def down
    change_column :infos, :description, :string
  end
end
