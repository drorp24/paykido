class AddFieldsToClists < ActiveRecord::Migration
  def change
    add_column :clists, :consumer_id, :integer
    add_column :clists, :rule, :string
  end
end
