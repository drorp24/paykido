class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :purchase_id
      t.string :ppp_status
      t.integer :PPP_TransactionID, :limit => 8
      t.integer :responsechecksum
      t.integer :TransactionID, :limit => 8
      t.string :status
      t.string :userid
      t.string :customData
      t.string :first_name
      t.string :last_name
      t.string :Email
      t.string :address1
      t.string :address2
      t.string :country
      t.string :state
      t.string :city
      t.string :zip
      t.string :phone1
      t.string :nameOnCard
      t.string :cardNumber
      t.string :expMonth
      t.string :expYear
      t.string :token
      t.string :CVV2
      t.string :IPAddress
      t.string :ExErrCode
      t.string :ErrCode
      t.string :AuthCode
      t.string :message
      t.string :responseTimeStamp
      t.string :Reason
      t.string :ReasonCode

      t.timestamps
    end
  end
end
