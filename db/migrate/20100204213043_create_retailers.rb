class CreateRetailers < ActiveRecord::Migration
  def self.up
    create_table :retailers do |t|
      
      t.string    :username, :null => false
      t.string    :hashed_password
      t.string    :salt
      
      t.string    :name
      t.string    :email
      
      t.decimal   :collected
      t.decimal   :billed

      t.timestamps
    end
  end

  def self.down
    drop_table :retailers
  end
end
