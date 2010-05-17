class AddPhoneEventsToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :phone_events, :string
  end

  def self.down
    remove_column :payers, :phone_events
  end
end
