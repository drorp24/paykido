class AddValueToInfos < ActiveRecord::Migration
  def change
    add_column :infos, :value, :string
    
    add_index :infos, [:key, :value], :unique => true
  end
end
