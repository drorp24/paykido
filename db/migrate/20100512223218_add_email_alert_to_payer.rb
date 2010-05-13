class AddEmailAlertToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :email_alert, :boolean
  end

  def self.down
    remove_column :payers, :email_alert
  end
end
