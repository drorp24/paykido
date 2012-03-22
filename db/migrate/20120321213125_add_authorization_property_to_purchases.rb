class AddAuthorizationPropertyToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :authorization_property, :string
  end
end
