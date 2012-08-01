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

ActiveRecord::Schema.define(:version => 20120730154009) do

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
    t.integer   "payer_id"
    t.string    "event"
    t.string    "medium"
    t.string    "data"
    t.string    "frequency"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "payers", :force => true do |t|
    t.boolean   "exists"
    t.string    "name"
    t.string    "email"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "phone"
    t.boolean   "email_alert"
    t.string    "hashed_password"
    t.string    "salt"
  end

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
    t.integer   "payer_id",               :null => false
    t.decimal   "amount",                 :null => false
    t.date      "date",                   :null => false
    t.timestamp "authorization_date"
    t.string    "authorization_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "authorized"
    t.integer   "consumer_id"
    t.integer   "category_id"
    t.string    "properties"
    t.integer   "title_id"
    t.string    "product"
    t.string    "title"
    t.text      "params"
    t.string    "authorization_property"
    t.string    "authorization_value"
    t.integer   "retailer_id"
    t.integer   "PP_TransactionID"
    t.string    "currency"
  end

  create_table "registrations", :force => true do |t|
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
    t.integer  "payer_id"
    t.integer  "consumer_id"
    t.string   "entity"
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "property"
    t.string   "value"
    t.string   "status"
  end

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

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

end
