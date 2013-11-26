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

ActiveRecord::Schema.define(version: 20130919021256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "album_ownerships", id: false, force: true do |t|
    t.uuid     "user_id"
    t.uuid     "album_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "role",       default: "owner"
  end

  add_index "album_ownerships", ["album_id"], name: "index_album_ownerships_on_album_id", using: :btree
  add_index "album_ownerships", ["user_id"], name: "index_album_ownerships_on_user_id", using: :btree

  create_table "albums", id: false, force: true do |t|
    t.uuid     "id",                         null: false
    t.string   "title"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "begins_at"
    t.boolean  "display_age", default: true
  end

  create_table "comments", force: true do |t|
    t.uuid     "posting_id"
    t.uuid     "user_id"
    t.text     "message"
    t.string   "state"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", force: true do |t|
    t.uuid     "user_id"
    t.string   "email"
    t.text     "message"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_files", id: false, force: true do |t|
    t.uuid     "id",                                   null: false
    t.uuid     "user_id"
    t.string   "original_name"
    t.string   "extension"
    t.string   "sha1"
    t.integer  "original_width"
    t.integer  "original_height"
    t.integer  "orientation"
    t.float    "ratio"
    t.string   "resolutions",                                       array: true
    t.string   "state",              default: "blank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format"
    t.integer  "original_file_size"
  end

  create_table "invitations", id: false, force: true do |t|
    t.uuid     "id",                               null: false
    t.uuid     "user_id"
    t.text     "message"
    t.string   "recipient_email"
    t.uuid     "recipient_id"
    t.string   "album_ids",                                     array: true
    t.string   "state",           default: "open"
    t.string   "token"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",          default: "en"
  end

  create_table "media_sources", id: false, force: true do |t|
    t.uuid     "id",         null: false
    t.uuid     "user_id"
    t.string   "provider",   null: false
    t.hstore   "meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "postings", id: false, force: true do |t|
    t.uuid     "id",                            null: false
    t.string   "title"
    t.text     "body"
    t.string   "state",       default: "blank"
    t.uuid     "album_id"
    t.uuid     "user_id"
    t.uuid     "media_id"
    t.string   "media_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "geo_lat"
    t.float    "geo_long"
    t.string   "geo_loc"
    t.datetime "recorded_at"
    t.integer  "disc_usage"
  end

  create_table "subscriptions", id: false, force: true do |t|
    t.uuid     "id",         null: false
    t.uuid     "album_id"
    t.uuid     "user_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["album_id"], name: "index_subscriptions_on_album_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", id: false, force: true do |t|
    t.uuid     "id",                                     null: false
    t.string   "name"
    t.string   "role"
    t.string   "phone"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mail_token"
    t.string   "locale",                 default: "en"
    t.integer  "max_albums",             default: 0
    t.boolean  "reviewed",               default: true
    t.boolean  "pseudo",                 default: false
    t.string   "pseudo_password"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "video_files", id: false, force: true do |t|
    t.uuid     "id",                 null: false
    t.uuid     "user_id"
    t.string   "original_name"
    t.string   "extension"
    t.string   "sha1"
    t.integer  "original_width"
    t.integer  "original_height"
    t.integer  "duration"
    t.integer  "orientation"
    t.float    "ratio"
    t.string   "state"
    t.hstore   "meta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_file_size"
    t.integer  "original_duration"
    t.integer  "auto_rotated"
    t.hstore   "resolutions"
  end

end
