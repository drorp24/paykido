class AddCurrencyToRules < ActiveRecord::Migration
  def change
    add_column :rules, :currency, :string
  end
end
