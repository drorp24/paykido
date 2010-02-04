class CreatePayers < ActiveRecord::Migration
  def self.up
    create_table :payers do |t|
      t.string :name
      t.string :email
      t.string :pay_type
      t.string :username
      t.string :hashed_password
      t.string :salt
      t.decimal :balance

      t.timestamps
    end
  end

  def self.down
    drop_table :payers
  end
end
