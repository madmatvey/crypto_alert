# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_13_083750) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alert_notifications", force: :cascade do |t|
    t.bigint "alert_id", null: false
    t.bigint "notification_channel_id", null: false
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_alert_notifications_on_alert_id"
    t.index ["notification_channel_id"], name: "index_alert_notifications_on_notification_channel_id"
  end

  create_table "alerts", force: :cascade do |t|
    t.string "symbol", null: false
    t.integer "direction", null: false
    t.decimal "threshold_price", precision: 18, scale: 8, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction"], name: "index_alerts_on_direction"
    t.index ["symbol", "direction"], name: "index_alerts_on_symbol_and_direction"
    t.index ["symbol"], name: "index_alerts_on_symbol"
  end

  create_table "notification_channels", force: :cascade do |t|
    t.integer "kind", null: false
    t.jsonb "settings", default: {}, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_notification_channels_on_kind"
  end

  add_foreign_key "alert_notifications", "alerts"
  add_foreign_key "alert_notifications", "notification_channels"
end
