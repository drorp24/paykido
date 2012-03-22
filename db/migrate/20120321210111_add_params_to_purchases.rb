class AddParamsToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :params, :text
  end
end
