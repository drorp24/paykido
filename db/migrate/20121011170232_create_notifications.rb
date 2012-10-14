class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :purchase_id
      t.string :response
      t.string :orderid
      t.string :status
      t.decimal :amount
      t.string :currency
      t.string :reason
      t.string :checksum
      t.string :event

      t.timestamps
    end
  end
end
