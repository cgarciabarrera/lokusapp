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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141121113224) do

  create_table "alarm_locations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.boolean  "warns_on_in",   default: true
    t.integer  "device_id"
    t.integer  "current_state", default: 0
    t.integer  "user_id"
  end

  create_table "alarms", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cart_items", force: true do |t|
    t.integer "owner_id"
    t.string  "owner_type"
    t.integer "quantity"
    t.integer "item_id"
    t.string  "item_type"
    t.float   "price"
  end

  create_table "devices", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "type_id"
    t.boolean  "active",          default: true
    t.boolean  "available",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "imei"
    t.datetime "last_ack"
    t.integer  "position_status", default: 0
    t.boolean  "gps_status",      default: false
  end

  create_table "items", force: true do |t|
    t.string   "name"
    t.decimal  "price",      precision: 8,  scale: 2, default: 0.0
    t.decimal  "tax",        precision: 10, scale: 0
    t.datetime "last_fix"
    t.boolean  "active",                              default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
  end

  create_table "locations", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.float    "lat"
    t.float    "lon"
    t.integer  "radius"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "shareds", force: true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.integer  "user_shared_id"
    t.boolean  "visible",        default: true
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
