class AddAuthorizationValueToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :authorization_value, :string
  end
end
