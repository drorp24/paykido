class RemoveFieldsFromPayer < ActiveRecord::Migration
  def up
    remove_column :payers, :pp_preapprovalKey
    remove_column :payers, :pp_startingDate
    remove_column :payers, :pp_endingDate
    remove_column :payers, :pp_maxNumberOfPayments
    remove_column :payers, :pp_maxAmountPerPayment
    remove_column :payers, :pp_pinType
    remove_column :payers, :family
    remove_column :payers, :exists
    remove_column :payers, :pin
    remove_column :payers, :phone_alert
    remove_column :payers, :email_alert
    remove_column :payers, :phone_alert_frequency
    remove_column :payers, :email_alert_frequency
    remove_column :payers, :phone_events
    remove_column :payers, :email_events
    remove_column :payers, :billing_id
    remove_column :payers, :skype
    remove_column :payers, :facebook
   # remove_column :payers, :exists

  end

  def down
    add_column :payers, :pp_preapprovalKey,         :string
    add_column :payers, :pp_startingDate,           :datetime
    add_column :payers, :pp_endingDate,             :datetime
    add_column :payers, :pp_maxNumberOfPayments,    :integer
    add_column :payers, :pp_maxAmountPerPayment,    :decimal
    add_column :payers, :pp_pinType,                :string
    add_column :payers, :family,                    :string
    add_column :payers, :exists,                    :boolean
    add_column :payers, :pin,                       :string
    add_column :payers, :phone_alert,               :boolean
    add_column :payers, :email_alert,               :boolean
    add_column :payers, :phone_alert_frequency,     :string
    add_column :payers, :email_alert_frequency,     :string
    add_column :payers, :phone_events,              :string
    add_column :payers, :email_events,              :string
    add_column :payers, :billing_id,                :string
    add_column :payers, :skype,                     :string
    add_column :payers, :facebook,                  :string
  #  add_column :payers, :exists,                    :boolean

  end
end
