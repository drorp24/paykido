class RemoveExistsFromPayer < ActiveRecord::Migration
  def up
    remove_column :payers, :exists
  end

  def down
    add_column :payers, :exists, :boolean
  end
end
