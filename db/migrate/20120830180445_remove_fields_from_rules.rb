class RemoveFieldsFromRules < ActiveRecord::Migration
  def up
    remove_column :rules, :payer_id
    remove_column :rules, :entity
    remove_column :rules, :entity_id
    add_column    :rules, :schedule, :text
  end

  def down
    add_column :rules, :entity_id, :integer
    add_column :rules, :entity, :string
    add_column :rules, :payer_id, :integer
    remove_column      :rules, :schedule

  end
end
