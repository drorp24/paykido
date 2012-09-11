class CreateAllowances < ActiveRecord::Migration
  def change
    create_table :allowances do |t|
      t.integer :consumer_id
      t.string :kind
      t.decimal :amount
      t.text :schedule

      t.timestamps
    end
  end
end
