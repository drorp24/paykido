class CreatePayers < ActiveRecord::Migration
  def self.up
    create_table :payers do |t|
      t.boolean :exists
      t.string :user
      t.string :hashed_password
      t.string :salt
      t.string :name
      t.string :email
      t.decimal :balance, :precision => 8, :scale => 2, :default => 0
      t.string :pin

      t.timestamps
    end
  end

  def self.down
    drop_table :payers
  end
end
