class AddFieldsToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :ExErrCode, :string
    add_column :registrations, :ErrCode, :string
    add_column :registrations, :AuthCode, :string
    add_column :registrations, :messgae, :string
    add_column :registrations, :responseTimeStamp, :string
    add_column :registrations, :Reason, :string
    add_column :registrations, :ReasonCode, :string
  end
end
