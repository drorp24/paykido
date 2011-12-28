class AddAllowanceFieldsToConsumer < ActiveRecord::Migration
  def change
    add_column :consumers, :allowance, :decimal
    add_column :consumers, :allowance_period, :string
    add_column :consumers, :allowance_change_date, :datetime
    add_column :consumers, :balance_on_acd, :decimal
    add_column :consumers, :purchases_since_acd, :decimal
    add_column :consumers, :auto_authorize_under, :decimal
    add_column :consumers, :auto_deny_over, :decimal
    remove_column :consumers, :balance
  end
end
