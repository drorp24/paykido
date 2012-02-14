class AddAllowanceEveryToConsumer < ActiveRecord::Migration
  def change
    add_column :consumers, :allowance_every, :integer
  end
end
