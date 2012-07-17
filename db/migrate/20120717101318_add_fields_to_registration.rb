class AddFieldsToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :ppp_status, :string
    add_column :registrations, :PPP_TransactionID, :string
    add_column :registrations, :client_ip, :string
    add_column :registrations, :cardNumber, :string
    add_column :registrations, :uniqueCC, :string
  end
end
