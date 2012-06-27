class RemoveRegisteredFromPayer < ActiveRecord::Migration
  def up
    remove_column :payers, :registered
  end

  def down
    add_column :payers, :registered, :boolean
  end
end
