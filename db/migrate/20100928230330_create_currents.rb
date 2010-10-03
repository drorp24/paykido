class CreateCurrents < ActiveRecord::Migration
  def self.up
    create_table :currents do |t|
      
      t.boolean :check_pendings
      t.boolean :send_sms
      t.boolean :online

      t.timestamps
    end

  end

  def self.down
    drop_table :currents
  end

end
