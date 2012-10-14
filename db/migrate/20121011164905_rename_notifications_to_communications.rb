class RenameNotificationsToCommunications < ActiveRecord::Migration
def change
  rename_table :notifications, :communications
end
end
