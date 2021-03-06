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

ActiveRecord::Schema.define(version: 20140530053457) do

  create_table "alert_logs", force: true do |t|
    t.integer  "alert_id"
    t.integer  "alertable_id"
    t.string   "alertable_type"
    t.boolean  "acknowledged"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "projection"
    t.string   "noid"
  end

  create_table "alerts", force: true do |t|
    t.boolean  "enabled"
    t.string   "name"
    t.text     "description"
    t.string   "int_type"
    t.integer  "link_type_id"
    t.string   "match_regex"
    t.integer  "percentile"
    t.float    "watermark"
    t.integer  "days_out"
    t.integer  "contact_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "days_back"
    t.integer  "severity"
  end

  create_table "averages", force: true do |t|
    t.integer  "averageable_id"
    t.string   "averageable_type"
    t.string   "noid"
    t.integer  "percentile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gauge",            limit: 8
  end

  create_table "contact_groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "email_addresses"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_autoconf_rules", force: true do |t|
    t.boolean  "enabled"
    t.string   "network"
    t.string   "hostname_regex"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: true do |t|
    t.string   "description"
    t.string   "hostname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "snmp_id"
  end

  create_table "interface_autoconf_rules", force: true do |t|
    t.boolean  "enabled"
    t.string   "name_regex"
    t.string   "description_regex"
    t.integer  "link_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interface_group_relationships", force: true do |t|
    t.integer  "interface_id"
    t.integer  "interface_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interface_groups", force: true do |t|
    t.string   "description"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "refresh_next_import"
    t.datetime "import_checkpoint"
  end

  create_table "interfaces", force: true do |t|
    t.integer  "device_id"
    t.string   "description"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "link_type_id"
    t.integer  "bandwidth",         limit: 8
    t.datetime "import_checkpoint"
  end

  create_table "link_types", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurements", force: true do |t|
    t.integer  "interface_id"
    t.datetime "collected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percentile"
    t.string   "noid"
    t.integer  "gauge",        limit: 8
  end

  create_table "settings", force: true do |t|
    t.integer  "slice_size"
    t.integer  "default_percentile"
    t.float    "default_watermark"
    t.integer  "max_hist_dist"
    t.integer  "default_hist_dist"
    t.string   "zpoller_rc_location"
    t.string   "zconfig_location"
    t.string   "zpoller_hosts_location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mongodb_test_window"
    t.string   "zpoller_base_dir"
    t.string   "mongodb_db_hostname"
    t.integer  "mongodb_db_port"
    t.string   "mongodb_db_name"
    t.integer  "link_group_importer_lookback_window"
    t.integer  "zpoller_poller_interval"
    t.string   "mailhost"
    t.integer  "polling_interval_secs"
    t.integer  "max_trending_future_days"
    t.integer  "min_alert_measurements_percent"
    t.integer  "min_bps_for_inclusion",               limit: 8
    t.string   "source_email_address"
    t.integer  "average_previous_hours"
  end

  create_table "snmps", force: true do |t|
    t.string   "name"
    t.string   "community_string"
    t.boolean  "default_community"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "srlg_measurements", force: true do |t|
    t.integer  "interface_group_id"
    t.datetime "collected_at"
    t.integer  "percentile"
    t.string   "noid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gauge",              limit: 8
  end

  create_table "users", force: true do |t|
    t.string   "login",               default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

end
