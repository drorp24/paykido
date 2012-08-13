class RenameRegistrationsToTokens < ActiveRecord::Migration
    def change
        rename_table :registrations, :tokens
    end 
end
