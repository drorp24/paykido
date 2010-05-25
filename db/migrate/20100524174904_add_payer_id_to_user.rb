class AddPayerIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :payer_id, :integer
  end

  def self.down
    remove_column :users, :payer_id
  end
end
