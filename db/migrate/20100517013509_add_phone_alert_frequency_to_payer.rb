class AddPhoneAlertFrequencyToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :phone_alert_frequency, :string
  end

  def self.down
    remove_column :payers, :phone_alert_frequency
  end
end
