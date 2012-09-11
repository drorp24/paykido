class RemoveKindFromRules < ActiveRecord::Migration
  def up
    remove_column :rules, :kind
  end

  def down
    add_column :rules, :kind, :string
  end
end
