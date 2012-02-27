class RemoveObsoleteFromPurchases < ActiveRecord::Migration
  def up
    remove_column :purchases, :billing_date
    remove_column :purchases, :billing_type
    remove_column :purchases, :authentication_date
    remove_column :purchases, :authentication_type
    remove_column :purchases, :expected_pin
    remove_column :purchases, :location
  end

  def down
    add_column :purchases, :location, :string
    add_column :purchases, :expected_pin, :string
    add_column :purchases, :authentication_type, :text
    add_column :purchases, :authentication_date, :datetime
    add_column :purchases, :billing_type, :integer
    add_column :purchases, :billing_date, :date
  end
end
