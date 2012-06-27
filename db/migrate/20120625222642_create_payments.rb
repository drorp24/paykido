class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :purchase_id
      t.string :CustomData
      t.integer :UserID
      t.integer :ClientUniqueID
      t.integer :TransactionID
      t.string :Status
      t.string :AuthCode
      t.string :Reason
      t.string :ErrCode
      t.string :ExErrCode
      t.string :Token
      t.text :Params

      t.timestamps
    end
  end
end
