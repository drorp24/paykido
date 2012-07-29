class RemoveActionFromRule < ActiveRecord::Migration
  def up
    remove_column :rules, :action
  end

  def down
    add_column :rules, :action, :string
  end
end
