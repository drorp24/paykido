class ChangeChecksumInTransaction < ActiveRecord::Migration
  def up
    change_column :transactions, :responsechecksum, :string
    change_column :transactions, :PPP_TransactionID, :string
    change_column :transactions, :TransactionID, :string
  end

  def down
    change_column :transactions, :responsechecksum, :integer
    change_column :transactions, :PPP_TransactionID, :integer
    change_column :transactions, :TransactionID, :integer
  end
end
