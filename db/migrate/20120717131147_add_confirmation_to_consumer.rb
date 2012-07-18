class AddConfirmationToConsumer < ActiveRecord::Migration
  def change
    add_column :consumers, :confirmed, :boolean
    add_column :consumers, :confirmed_at, :timestamp
  end
end
