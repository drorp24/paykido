class AddPhoneAlertToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :phone_alert, :boolean
  end

  def self.down
    remove_column :payers, :phone_alert
  end
end
