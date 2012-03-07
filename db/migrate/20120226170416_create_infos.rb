class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.string :key,  :null => false
      t.string :title
      t.string :description
      t.string :logo

      t.timestamps
    end
  end
end
