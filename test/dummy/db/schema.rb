# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_19_154646) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delay_henka_scheduled_actions", force: :cascade do |t|
    t.string "actionable_type", null: false
    t.bigint "actionable_id", null: false
    t.string "method_name", null: false
    t.string "state", null: false
    t.string "error_message"
    t.integer "submitted_by_id", comment: "Legacy. Deprecated in favor of submitted_by_email, which stores just an email"
    t.datetime "schedule_at", null: false
    t.jsonb "argument"
    t.jsonb "return_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone"
    t.integer "service_region_id"
    t.string "submitted_by_email"
    t.index ["actionable_type", "actionable_id"], name: "actionable_index"
    t.index ["schedule_at"], name: "index_delay_henka_scheduled_actions_on_schedule_at"
    t.index ["state"], name: "index_delay_henka_scheduled_actions_on_state"
    t.index ["time_zone"], name: "index_delay_henka_scheduled_actions_on_time_zone"
  end

  create_table "delay_henka_scheduled_changes", force: :cascade do |t|
    t.string "changeable_type", null: false
    t.integer "changeable_id", null: false
    t.string "attribute_name", null: false
    t.integer "submitted_by_id", comment: "Legacy. Deprecated in favor of submitted_by_email, which stores just an email"
    t.string "state", null: false
    t.text "error_message"
    t.jsonb "old_value"
    t.jsonb "new_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "schedule_at", null: false
    t.string "time_zone"
    t.integer "service_region_id"
    t.string "submitted_by_email"
    t.index ["time_zone"], name: "index_delay_henka_scheduled_changes_on_time_zone"
  end

end
