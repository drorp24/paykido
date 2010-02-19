class CreatePayers < ActiveRecord::Migration
  def self.up
    create_table :payers do |t|
      
      t.string :username
      t.string :hashed_password
      t.string :salt
      
      t.string :name
      t.string :email
      
      t.decimal :balance

      t.timestamps
    end
  end

  def self.down
    drop_table :payers
  end
end
