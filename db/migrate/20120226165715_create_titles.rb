class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.string :name
      t.string :esrb_rating
      t.string :esrb_descriptor
      t.boolean :posc
      t.integer :pegi_age_rating_id
      t.integer :pegi_descriptor_id

      t.timestamps
    end
  end
end
