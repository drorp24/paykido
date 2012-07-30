class AddStatusToRule < ActiveRecord::Migration
  def change
    add_column :rules, :status, :string
  end
end
