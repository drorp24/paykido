class AddByToAllowance < ActiveRecord::Migration
  def change
    add_column :allowances, :by, :string
  end
end
