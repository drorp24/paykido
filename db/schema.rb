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

ActiveRecord::Schema.define(:version => 20111218092521) do

  create_table "billings", :force => true do |t|
    t.string    "method",     :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string    "name",       :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "logo"
  end

  create_table "clists", :force => true do |t|
    t.integer   "payer_id",    :null => false
    t.integer   "category_id", :null => false
    t.string    "status"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "configs", :force => true do |t|
    t.boolean   "check_pendings"
    t.boolean   "send_sms"
    t.boolean   "online"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "consumers", :force => true do |t|
    t.string    "billing_phone"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.decimal   "balance"
    t.string    "pin"
    t.string    "name"
    t.string    "pic"
    t.string    "facebook_id"
    t.integer   "payer_id"
    t.string    "facebook_access_token"
    t.string    "tinypic"
  end

  add_index "consumers", ["billing_phone"], :name => "index_consumers_on_billing_phone"

  create_table "currents", :force => true do |t|
    t.boolean   "check_pendings"
    t.boolean   "send_sms"
    t.boolean   "online"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer   "retailer_id", :null => false
    t.integer   "product_id",  :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "items", ["product_id", "retailer_id"], :name => "index_items_on_product_id_and_retailer_id", :unique => true
  add_index "items", ["retailer_id"], :name => "index_items_on_retailer_id"

  create_table "line_items", :force => true do |t|
    t.integer   "product_id",  :null => false
    t.integer   "order_id",    :null => false
    t.integer   "quantity",    :null => false
    t.decimal   "total_price", :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.string    "name"
    t.text      "address"
    t.string    "email"
    t.string    "pay_type",   :limit => 10
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "payer_rule_categories", :force => true do |t|
    t.integer   "payer_rule_id", :null => false
    t.integer   "category_id",   :null => false
    t.integer   "approved"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "payer_rules", :force => true do |t|
    t.decimal   "allowance"
    t.boolean   "rollover"
    t.decimal   "auto_authorize_under"
    t.decimal   "auto_deny_over"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "consumer_id"
    t.integer   "payer_id"
  end

  create_table "payers", :force => true do |t|
    t.string    "name"
    t.string    "email"
    t.string    "pin"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "phone"
    t.boolean   "phone_alert"
    t.boolean   "email_alert"
    t.string    "phone_alert_frequency"
    t.string    "email_alert_frequency"
    t.string    "phone_events"
    t.string    "email_events"
    t.boolean   "exists"
    t.integer   "billing_id"
    t.string    "skype"
    t.string    "facebook"
    t.boolean   "registered"
    t.string    "pp_preapprovalKey"
    t.timestamp "pp_startingDate"
    t.timestamp "pp_endingDate"
    t.integer   "pp_maxNumberOfPayments"
    t.decimal   "pp_maxAmountPerPayment"
    t.string    "pp_pinType"
    t.string    "family"
  end

  create_table "plists", :force => true do |t|
    t.integer   "payer_id",   :null => false
    t.integer   "product_id", :null => false
    t.string    "status"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer   "category_id",                  :null => false
    t.string    "title",                        :null => false
    t.text      "description"
    t.string    "image_url"
    t.decimal   "price",       :default => 0.0
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "logo"
  end

  add_index "products", ["title"], :name => "index_products_on_title"

  create_table "purchases", :force => true do |t|
    t.integer   "payer_id",            :null => false
    t.integer   "retailer_id",         :null => false
    t.integer   "product_id",          :null => false
    t.decimal   "amount",              :null => false
    t.timestamp "date",                :null => false
    t.timestamp "authorization_date"
    t.string    "authorization_type"
    t.date      "billing_date"
    t.integer   "billing_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "authentication_date"
    t.text      "authentication_type"
    t.boolean   "authorized"
    t.string    "expected_pin"
    t.string    "location"
    t.integer   "consumer_id"
  end

  create_table "retailers", :force => true do |t|
    t.string    "name"
    t.string    "email"
    t.decimal   "collected"
    t.decimal   "billed"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "logo"
  end

  create_table "rlists", :force => true do |t|
    t.integer   "payer_id",    :null => false
    t.integer   "retailer_id", :null => false
    t.string    "status"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string    "name"
    t.string    "hashed_password"
    t.string    "salt"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "retailer_id"
    t.integer   "payer_id"
    t.string    "affiliation"
    t.string    "role"
    t.string    "email"
  end

  create_table "versions", :force => true do |t|
    t.integer   "versioned_id"
    t.string    "versioned_type"
    t.integer   "user_id"
    t.string    "user_type"
    t.string    "user_name"
    t.text      "changes"
    t.integer   "number"
    t.string    "tag"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end
