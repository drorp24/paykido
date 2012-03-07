class AddValueToInfos < ActiveRecord::Migration
  def change
    add_column :infos, :value, :string,  :null => false
    
    add_index :infos, [:key, :value], :unique => true
  end
end
