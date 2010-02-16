# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100204213045) do

  create_table "billings", :force => true do |t|
    t.string   "type",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "product_id",                                :null => false
    t.integer  "order_id",                                  :null => false
    t.integer  "quantity",                                  :null => false
    t.decimal  "total_price", :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "email"
    t.string   "pay_type",   :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payer_rule_categories", :force => true do |t|
    t.integer  "payer_rule_id", :null => false
    t.integer  "category_id",   :null => false
    t.integer  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payer_rules", :force => true do |t|
    t.integer  "payer_id",           :null => false
    t.integer  "billing_id",         :null => false
    t.decimal  "allowance"
    t.boolean  "rollover"
    t.decimal  "auto_approve_under"
    t.decimal  "auto_reject_over"
    t.integer  "approval_phone"
    t.integer  "pin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payers", :force => true do |t|
    t.string   "username",        :null => false
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "name"
    t.string   "email"
    t.decimal  "balance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",       :precision => 8, :scale => 2, :default => 0.0
  end

  create_table "purchases", :force => true do |t|
    t.integer  "payer_id",      :null => false
    t.integer  "retailer_id",   :null => false
    t.integer  "product_id",    :null => false
    t.decimal  "amount",        :null => false
    t.date     "purchase_date", :null => false
    t.date     "approval_date"
    t.string   "approval_type"
    t.date     "billing_date"
    t.integer  "billing_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retailer_products", :force => true do |t|
    t.string   "retailer_id", :null => false
    t.string   "product_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retailers", :force => true do |t|
    t.string   "username",        :null => false
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "name"
    t.string   "email"
    t.decimal  "collected"
    t.decimal  "billed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscribers", :force => true do |t|
    t.string   "payer_id",      :null => false
    t.string   "billing_phone", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscribers", ["billing_phone"], :name => "index_subscribers_on_billing_phone"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
