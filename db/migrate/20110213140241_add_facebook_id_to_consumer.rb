class AddFacebookIdToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :facebook_id, :string
  end

  def self.down
    remove_column :consumers, :facebook_id
  end
end
