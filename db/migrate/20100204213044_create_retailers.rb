class CreateRetailers < ActiveRecord::Migration
  def self.up
    create_table :retailers do |t|
      t.string :name
      t.string :category_id
      t.decimal :collected
      t.decimal :billed

      t.timestamps
    end
  end

  def self.down
    drop_table :retailers
  end
end
