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

ActiveRecord::Schema.define(version: 20130713150955) do

  create_table "backends", force: true do |t|
    t.string   "kind",       limit: 16,  null: false
    t.string   "url",        limit: 128, null: false
    t.string   "http_url",   limit: 128, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_states", force: true do |t|
    t.integer  "match_id"
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.string   "backend_url",      null: false
    t.string   "backend_http_url", null: false
    t.string   "room_key",         null: false
    t.string   "join_key1",        null: false
    t.string   "join_key2",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chat_states", ["match_id"], name: "index_chat_states_on_match_id", unique: true, using: :btree
  add_index "chat_states", ["user1_id"], name: "index_chat_states_on_user1_id", using: :btree
  add_index "chat_states", ["user2_id"], name: "index_chat_states_on_user2_id", using: :btree

  create_table "config_vars", force: true do |t|
    t.string "name",  null: false
    t.binary "value", null: false
  end

  add_index "config_vars", ["name"], name: "index_config_vars_on_name", unique: true, using: :btree

  create_table "credentials", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "type",       limit: 32,   null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",              null: false
    t.binary   "key",        limit: 2048
  end

  add_index "credentials", ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
  add_index "credentials", ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
  add_index "credentials", ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree

  create_table "match_entries", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "other_user_id", null: false
    t.integer  "match_id",      null: false
    t.datetime "created_at",    null: false
    t.datetime "closed_at"
    t.boolean  "rejected"
  end

  add_index "match_entries", ["user_id", "created_at"], name: "index_match_entries_on_user_id_and_created_at", unique: true, using: :btree

  create_table "matches", force: true do |t|
    t.boolean  "rejected",   null: false
    t.datetime "created_at", null: false
  end

  create_table "profiles", force: true do |t|
    t.integer "user_id"
    t.string  "name",    null: false
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", unique: true, using: :btree

  create_table "queue_entries", force: true do |t|
    t.integer  "user_id",    null: false
    t.datetime "entered_at", null: false
    t.datetime "left_at"
    t.boolean  "abandoned"
    t.integer  "match_id"
  end

  add_index "queue_entries", ["user_id", "entered_at"], name: "index_queue_entries_on_user_id_and_entered_at", unique: true, using: :btree

  create_table "queue_states", force: true do |t|
    t.integer "user_id",                      null: false
    t.string  "join_key",         limit: 64,  null: false
    t.string  "match_key",        limit: 64,  null: false
    t.string  "backend_url",      limit: 128, null: false
    t.string  "backend_http_url", limit: 128, null: false
  end

  add_index "queue_states", ["match_key"], name: "index_queue_states_on_match_key", unique: true, using: :btree
  add_index "queue_states", ["user_id"], name: "index_queue_states_on_user_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "exuid",      limit: 32,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                 default: false
  end

  add_index "users", ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree

end
