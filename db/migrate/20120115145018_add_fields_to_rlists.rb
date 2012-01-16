class AddFieldsToRlists < ActiveRecord::Migration
  def change
    add_column :rlists, :consumer_id, :integer
    add_column :rlists, :rule, :string
  end
end
