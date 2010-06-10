class CreatePayers < ActiveRecord::Migration
  def self.up
    create_table :payers do |t|

      t.boolean :exists

      t.string  :name
      t.string  :email
      t.string  :pin

      t.timestamps
    end
  end

  def self.down
    drop_table :payers
  end
end
