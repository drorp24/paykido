class CreateRetailers < ActiveRecord::Migration
  def self.up
    create_table :retailers do |t|
      
      t.string    :user
      t.string    :hashed_password
      t.string    :salt
      
      t.string    :name
      t.string    :email
      
      t.decimal   :collected
      t.decimal   :billed

      t.timestamps
    end
    add_index :retailers, :username, :name
  end

  def self.down
    drop_table :retailers
  end
end
