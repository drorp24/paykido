class AddTmpPwdToPayers < ActiveRecord::Migration
  def change
    add_column :payers, :temporary_password, :string
  end
end
