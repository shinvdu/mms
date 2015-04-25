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

ActiveRecord::Schema.define(version: 20150424073150) do

  create_table "accounts", force: :cascade do |t|
    t.string   "username",               limit: 255, default: "", null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        limit: 4,   default: 0,  null: false
    t.datetime "locked_at"
    t.integer  "user_id",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "accounts", ["username"], name: "index_accounts_on_username", unique: true, using: :btree

  create_table "advertise_resources", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "file_type",  limit: 255
    t.string   "ad_type",    limit: 255
    t.integer  "filesize",   limit: 4
    t.string   "uri",        limit: 255
    t.text     "ad_word",    limit: 65535
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "advertise_strategies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id",    limit: 4
    t.integer  "front_ad",   limit: 4
    t.integer  "end_ad",     limit: 4
    t.integer  "pause_ad",   limit: 4
    t.integer  "float_ad",   limit: 4
    t.integer  "scroll_ad",  limit: 4
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "logos", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "uri",        limit: 255
    t.integer  "width",      limit: 4
    t.integer  "height",     limit: 4
    t.string   "filemime",   limit: 255
    t.integer  "filesize",   limit: 4
    t.string   "origname",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "user_id",       limit: 4
    t.string   "color",         limit: 255
    t.integer  "logo_id",       limit: 4
    t.string   "logo_position", limit: 255
    t.integer  "autoplay",      limit: 4
    t.integer  "share",         limit: 4
    t.integer  "full_screen",   limit: 4
    t.integer  "width",         limit: 4
    t.integer  "height",        limit: 4
    t.text     "data",          limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end
  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "user_videos", force: :cascade do |t|
    t.integer  "owner_id",          limit: 4
    t.integer  "original_video_id", limit: 4
    t.integer  "mini_video_id",     limit: 4
    t.integer  "logo_id",           limit: 4
    t.string   "videoName",         limit: 255
    t.string   "fileName",          limit: 255
    t.string   "extName",           limit: 255
    t.integer  "duration",          limit: 4
    t.integer  "status",            limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "users", primary_key: "uid", force: :cascade do |t|
    t.string   "nicename",          limit: 255
    t.integer  "role",              limit: 4
    t.integer  "sex",               limit: 4
    t.integer  "really_name",       limit: 4
    t.datetime "birthday"
    t.string   "signature",         limit: 255
    t.string   "avar",              limit: 255
    t.string   "location",          limit: 255
    t.string   "self_introduction", limit: 255
    t.string   "token",             limit: 255
    t.string   "scret_key",         limit: 255
    t.string   "mobile",            limit: 255
    t.string   "wechat",            limit: 255
    t.string   "qq",                limit: 255
    t.string   "weibo",             limit: 255
    t.string   "twitter_id",        limit: 255
    t.string   "facebook",          limit: 255
    t.string   "website",           limit: 255
    t.string   "note",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "video_cut_points", force: :cascade do |t|
    t.float    "start_time",    limit: 24
    t.float    "stop_time",     limit: 24
    t.boolean  "user_created",  limit: 1
    t.integer  "user_video_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "video_details", force: :cascade do |t|
    t.string   "uuid",          limit: 255
    t.string   "uri",           limit: 255
    t.string   "format",        limit: 255
    t.string   "md5",           limit: 255
    t.string   "rate",          limit: 255
    t.integer  "size",          limit: 4
    t.integer  "duration",      limit: 4
    t.integer  "status",        limit: 4
    t.integer  "user_video_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "video",         limit: 255
  end

  create_table "video_fragments", force: :cascade do |t|
    t.integer  "video_product_group_id", limit: 4
    t.integer  "video_cut_point_id",     limit: 4
    t.integer  "order",                  limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "video_product_groups", force: :cascade do |t|
    t.integer  "owner_id",        limit: 4
    t.integer  "user_video_id",   limit: 4
    t.integer  "video_config_id", limit: 4
    t.boolean  "published",       limit: 1
    t.time     "publish_start"
    t.time     "publish_stop"
    t.integer  "status",          limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
