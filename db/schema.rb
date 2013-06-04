# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130604172357) do

  create_table "allowances", :force => true do |t|
    t.integer  "consumer_id"
    t.string   "kind"
    t.decimal  "amount"
    t.text     "schedule"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "by"
  end

  create_table "communications", :force => true do |t|
    t.integer   "payer_id"
    t.string    "event"
    t.string    "medium"
    t.string    "data"
    t.string    "frequency"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "consumers", :force => true do |t|
    t.string    "billing_phone"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "pin"
    t.string    "name"
    t.string    "pic"
    t.string    "facebook_id"
    t.integer   "payer_id"
    t.string    "facebook_access_token"
    t.string    "tinypic"
    t.decimal   "allowance"
    t.string    "allowance_period"
    t.timestamp "allowance_change_date"
    t.decimal   "balance_on_acd"
    t.decimal   "purchases_since_acd"
    t.decimal   "auto_authorize_under"
    t.decimal   "auto_deny_over"
    t.integer   "allowance_every"
    t.boolean   "confirmed"
    t.datetime  "confirmed_at"
  end

  add_index "consumers", ["billing_phone"], :name => "index_consumers_on_billing_phone"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "infos", :force => true do |t|
    t.string    "key"
    t.string    "title"
    t.text      "description"
    t.string    "logo"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "value"
  end

  add_index "infos", ["key", "value"], :name => "index_infos_on_key_and_value", :unique => true

  create_table "notifications", :force => true do |t|
    t.integer  "purchase_id"
    t.string   "response"
    t.string   "orderid"
    t.string   "status"
    t.decimal  "amount"
    t.string   "currency"
    t.string   "reason"
    t.string   "checksum"
    t.string   "event"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
  end

  create_table "payers", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "temporary_password"
  end

  add_index "payers", ["authentication_token"], :name => "index_payers_on_authentication_token", :unique => true
  add_index "payers", ["email"], :name => "index_payers_on_email", :unique => true
  add_index "payers", ["reset_password_token"], :name => "index_payers_on_reset_password_token", :unique => true

  create_table "payments", :force => true do |t|
    t.integer   "purchase_id"
    t.string    "CustomData"
    t.integer   "UserID"
    t.integer   "ClientUniqueID"
    t.integer   "TransactionID"
    t.string    "Status"
    t.string    "AuthCode"
    t.string    "Reason"
    t.string    "ErrCode"
    t.string    "ExErrCode"
    t.string    "Token"
    t.text      "Params"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "purchases", :force => true do |t|
    t.integer  "payer_id",                               :null => false
    t.decimal  "amount",                                 :null => false
    t.date     "date",                                   :null => false
    t.datetime "authorization_date"
    t.string   "authorization_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "authorized"
    t.integer  "consumer_id"
    t.integer  "category_id"
    t.string   "properties"
    t.integer  "title_id"
    t.string   "product"
    t.string   "title"
    t.text     "params"
    t.string   "authorization_property"
    t.string   "authorization_value"
    t.integer  "retailer_id"
    t.integer  "PP_TransactionID"
    t.string   "currency"
    t.integer  "price_cents",            :default => 0
    t.string   "price_currency",         :default => ""
  end

  create_table "retailers", :force => true do |t|
    t.string    "name"
    t.string    "email"
    t.decimal   "collected"
    t.decimal   "billed"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "logo"
    t.string    "merchant_id"
    t.string    "merchant_site_id"
  end

  create_table "rules", :force => true do |t|
    t.integer  "consumer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "property"
    t.string   "value"
    t.string   "status"
    t.text     "schedule"
    t.string   "occasion"
    t.string   "donator"
    t.string   "category"
    t.integer  "amount_cents",    :default => 0
    t.string   "amount_currency", :default => ""
    t.string   "currency"
  end

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer  "payer_id"
    t.string   "property"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "titles", :force => true do |t|
    t.string    "name"
    t.string    "esrb_rating"
    t.string    "esrb_descriptor"
    t.boolean   "posc"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "pegi_rating"
    t.string    "pegi_descriptor"
    t.string    "category"
  end

  create_table "tokens", :force => true do |t|
    t.integer   "payer_id"
    t.string    "status"
    t.string    "NameOnCard"
    t.string    "CCToken"
    t.string    "ExpMonth"
    t.string    "ExpYear"
    t.integer   "TransactionID"
    t.string    "CVV2"
    t.string    "FirstName"
    t.string    "LastName"
    t.string    "Address"
    t.string    "City"
    t.string    "State"
    t.string    "Zip"
    t.string    "Country"
    t.string    "Phone"
    t.string    "Email"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "ExErrCode"
    t.string    "ErrCode"
    t.string    "AuthCode"
    t.string    "messgae"
    t.string    "responseTimeStamp"
    t.string    "Reason"
    t.string    "ReasonCode"
    t.string    "ppp_status"
    t.string    "PPP_TransactionID"
    t.string    "client_ip"
    t.string    "cardNumber"
    t.string    "uniqueCC"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "purchase_id"
    t.string   "ppp_status"
    t.string   "PPP_TransactionID"
    t.string   "responsechecksum"
    t.string   "TransactionID"
    t.string   "status"
    t.string   "userid"
    t.string   "customData"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "Email"
    t.string   "address1"
    t.string   "address2"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "phone1"
    t.string   "nameOnCard"
    t.string   "cardNumber"
    t.string   "expMonth"
    t.string   "expYear"
    t.string   "token"
    t.string   "CVV2"
    t.string   "IPAddress"
    t.string   "ExErrCode"
    t.string   "ErrCode"
    t.string   "AuthCode"
    t.string   "message"
    t.string   "responseTimeStamp"
    t.string   "Reason"
    t.string   "ReasonCode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "trx_type"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
