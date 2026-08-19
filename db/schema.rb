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

ActiveRecord::Schema[8.0].define(version: 2026_08_19_081648) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "courses", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.string "title", null: false
    t.string "provider"
    t.string "url"
    t.string "status", default: "planned", null: false
    t.string "level"
    t.integer "progress_percentage"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "purpose"
    t.integer "roadmap_position"
    t.index ["status"], name: "index_courses_on_status"
    t.index ["subject_id"], name: "index_courses_on_subject_id"
  end

  create_table "daily_goal_items", force: :cascade do |t|
    t.bigint "daily_goal_id", null: false
    t.string "text", null: false
    t.integer "position", default: 0, null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_goal_id", "position"], name: "index_daily_goal_items_on_daily_goal_id_and_position"
    t.index ["daily_goal_id"], name: "index_daily_goal_items_on_daily_goal_id"
  end

  create_table "daily_goals", force: :cascade do |t|
    t.date "date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_daily_goals_on_date", unique: true
  end

  create_table "default_goal_items", force: :cascade do |t|
    t.string "text", null: false
    t.integer "position", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_default_goal_items_on_active_and_position"
  end

  create_table "degree_subjects", force: :cascade do |t|
    t.bigint "degree_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["degree_id", "subject_id"], name: "index_degree_subjects_on_degree_id_and_subject_id", unique: true
    t.index ["degree_id"], name: "index_degree_subjects_on_degree_id"
    t.index ["subject_id"], name: "index_degree_subjects_on_subject_id"
  end

  create_table "degrees", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "status", default: "planned", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_degrees_on_status"
  end

  create_table "personal_project_subjects", force: :cascade do |t|
    t.bigint "personal_project_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["personal_project_id", "subject_id"], name: "index_pp_subjects_on_project_and_subject", unique: true
    t.index ["personal_project_id"], name: "index_personal_project_subjects_on_personal_project_id"
    t.index ["subject_id"], name: "index_personal_project_subjects_on_subject_id"
  end

  create_table "personal_projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "status", default: "idea", null: false
    t.text "goal"
    t.date "target_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_personal_projects_on_status"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "status", default: "not_started", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_subjects_on_status"
  end

  add_foreign_key "courses", "subjects"
  add_foreign_key "daily_goal_items", "daily_goals"
  add_foreign_key "degree_subjects", "degrees"
  add_foreign_key "degree_subjects", "subjects"
  add_foreign_key "personal_project_subjects", "personal_projects"
  add_foreign_key "personal_project_subjects", "subjects"
end
