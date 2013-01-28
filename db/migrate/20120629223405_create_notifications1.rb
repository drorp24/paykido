class CreateNotifications1 < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :payer_id
      t.string :event
      t.string :medium
      t.string :data
      t.string :frequency

      t.timestamps
    end
  end
end
