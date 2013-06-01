class MonetizeRule < ActiveRecord::Migration
  def change
    add_money :rules, :amount
  end
end
