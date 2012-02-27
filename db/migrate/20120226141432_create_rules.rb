class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.integer :payer_id
      t.integer :consumer_id
      t.string :entity
      t.integer :entity_id
      t.string :action

      t.timestamps
    end
  end
end
