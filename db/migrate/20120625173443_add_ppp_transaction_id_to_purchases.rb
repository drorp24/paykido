class AddPppTransactionIdToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :PPP_TransactionID, :integer, :limit => 8
    add_column :purchases, :currency, :string
  end
end
