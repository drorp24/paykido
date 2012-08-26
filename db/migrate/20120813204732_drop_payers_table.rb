class DropPayersTable < ActiveRecord::Migration
  def up
    drop_table :payers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
