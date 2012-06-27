class RenamePppTransactionIdToPpTransactionId < ActiveRecord::Migration
def change
    rename_column :purchases, :PPP_TransactionID, :PP_TransactionID
  end
end
