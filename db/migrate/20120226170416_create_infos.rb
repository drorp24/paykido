class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.integer :key
      t.string :title
      t.string :description
      t.string :logo

      t.timestamps
    end
  end
end
