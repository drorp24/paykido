class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :payer_id
      t.string :property
      t.string :value

      t.timestamps
    end
  end
end
