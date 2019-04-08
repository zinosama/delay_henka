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

ActiveRecord::Schema.define(version: 2019_04_08_130947) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delay_henka_scheduled_actions", force: :cascade do |t|
    t.string "actionable_type", null: false
    t.bigint "actionable_id", null: false
    t.string "method_name"
    t.text "arguments", default: [], array: true
    t.string "state", null: false
    t.string "error_message"
    t.integer "submitted_by_id", null: false
    t.datetime "schedule_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actionable_type", "actionable_id"], name: "actionable_index"
    t.index ["schedule_at"], name: "index_delay_henka_scheduled_actions_on_schedule_at"
    t.index ["state"], name: "index_delay_henka_scheduled_actions_on_state"
  end

  create_table "delay_henka_scheduled_changes", force: :cascade do |t|
    t.string "changeable_type", null: false
    t.integer "changeable_id", null: false
    t.string "attribute_name", null: false
    t.integer "submitted_by_id", null: false
    t.string "state", null: false
    t.text "error_message"
    t.jsonb "old_value"
    t.jsonb "new_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "schedule_at", null: false
  end

end
