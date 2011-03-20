class AddFacebookAccessTokenToConsumer < ActiveRecord::Migration
  def self.up
    add_column :consumers, :facebook_access_token, :string
  end

  def self.down
    remove_column :consumers, :facebook_access_token
  end
end
