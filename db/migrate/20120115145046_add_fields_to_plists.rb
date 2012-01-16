class AddFieldsToPlists < ActiveRecord::Migration
  def change
    add_column :plists, :consumer_id, :integer
    add_column :plists, :rule, :string
  end
end
