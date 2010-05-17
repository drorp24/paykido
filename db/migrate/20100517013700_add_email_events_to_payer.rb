class AddEmailEventsToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :email_events, :string
  end

  def self.down
    remove_column :payers, :email_events
  end
end
