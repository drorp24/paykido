class AddTrxTypeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :trx_type, :string
  end
end
