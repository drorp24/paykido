class AddEmailAlertFrequencyToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :email_alert_frequency, :string
  end

  def self.down
    remove_column :payers, :email_alert_frequency
  end
end
