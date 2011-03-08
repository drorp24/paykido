class AddPaypalToPayer < ActiveRecord::Migration
  def self.up
    add_column :payers, :pp_preapprovalKey, :string
    add_column :payers, :pp_startingDate, :datetime
    add_column :payers, :pp_endingDate, :datetime
    add_column :payers, :pp_maxNumberOfPayments, :integer
    add_column :payers, :pp_maxAmountPerPayment, :decimal
    add_column :payers, :pp_pinType, :string
    add_column :payers, :family, :string
  end

  def self.down
    remove_column :payers, :family
    remove_column :payers, :pp_pinType
    remove_column :payers, :pp_maxAmountPerPayment
    remove_column :payers, :pp_maxNumberOfPayments
    remove_column :payers, :pp_endingDate
    remove_column :payers, :pp_startingDate
    remove_column :payers, :pp_preapprovalKey
  end
end
