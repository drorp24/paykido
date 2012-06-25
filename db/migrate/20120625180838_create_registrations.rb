class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :payer_id
      t.string :status
      t.string :NameOnCard
      t.string :CCToken
      t.string :ExpMonth
      t.string :ExpYear
      t.integer :TransactionID, :limit => 8
      t.string :CVV2
      t.string :FirstName
      t.string :LastName
      t.string :Address
      t.string :City
      t.string :State
      t.string :Zip
      t.string :Country
      t.string :Phone
      t.string :Email

      t.timestamps
    end
  end
end
