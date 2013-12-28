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

ActiveRecord::Schema.define(version: 20131228015321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answer_attributes", force: true do |t|
    t.boolean  "is_correct"
    t.float    "score"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.index ["question_id"], :name => "index_answer_attributes_on_question_id"
  end

  create_table "answers", force: true do |t|
    t.text     "response"
    t.integer  "question_id"
    t.integer  "user_id"
    t.float    "predicted_score"
    t.float    "current_score"
    t.integer  "evaluations_wanted"
    t.integer  "total_evaluations"
    t.float    "confidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",              default: "identify"
    t.string   "evaluation_type",    default: "default"
    t.boolean  "staff_graded",       default: false
    t.integer  "push_count",         default: 0
    t.string   "revision_name"
    t.index ["question_id"], :name => "index_answers_on_question_id"
    t.index ["user_id"], :name => "index_answers_on_user_id"
  end

  create_table "questions", force: true do |t|
    t.text     "title"
    t.text     "explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "min_score",                default: 0.0
    t.float    "max_score",                default: 1.0
    t.text     "baseline_explanation"
    t.string   "score_aggregation_method", default: "sum"
  end

  create_table "appeals", force: true do |t|
    t.text     "comments"
    t.integer  "answer_id"
    t.boolean  "accepted"
    t.boolean  "inspected"
    t.float    "appeal_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "experimental_condition"
    t.text     "instructor_comments"
    t.integer  "question_id"
    t.text     "answer_text"
    t.index ["answer_id"], :name => "fk__appeals_answer_id"
    t.index ["question_id"], :name => "fk__appeals_question_id"
    t.foreign_key ["answer_id"], "answers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_appeals_answer_id"
    t.foreign_key ["question_id"], "questions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_appeals_question_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",                           null: false
    t.string   "encrypted_password",     default: "",                           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",              default: "Pacific Time (US & Canada)"
    t.text     "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "gender"
    t.boolean  "admin"
    t.integer  "cid"
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  end

  create_table "assessments", force: true do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.text     "comments"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.string   "answer_type"
    t.index ["answer_id"], :name => "fk__assessments_answer_id"
    t.index ["question_id"], :name => "fk__assessments_question_id"
    t.index ["user_id"], :name => "fk__assessments_user_id"
    t.foreign_key ["answer_id"], "answers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_assessments_answer_id"
    t.foreign_key ["question_id"], "questions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_assessments_question_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_assessments_user_id"
  end

  create_table "attached_assets", force: true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id_"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assetable_type", "assetable_id_"], :name => "idx_ckeditor_assetable"
    t.index ["assetable_type", "type", "assetable_id_"], :name => "idx_ckeditor_assetable_type"
  end

  create_table "courses", force: true do |t|
    t.text     "title"
    t.text     "institution"
    t.boolean  "hidden",             default: true
    t.boolean  "open_enrollment",    default: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.index ["user_id"], :name => "fk__courses_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_courses_user_id"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], :name => "delayed_jobs_priority"
  end

  create_table "evaluations", force: true do |t|
    t.integer  "question_id"
    t.integer  "answer_id"
    t.integer  "answer_attribute_id"
    t.integer  "verified_true_count",  default: 0
    t.integer  "verified_false_count", default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessment_id"
    t.integer  "score"
    t.index ["answer_attribute_id"], :name => "index_evaluations_on_answer_attribute_id"
    t.index ["answer_id"], :name => "index_evaluations_on_answer_id"
    t.index ["assessment_id"], :name => "index_evaluations_on_assessment_id"
    t.index ["question_id"], :name => "index_evaluations_on_question_id"
    t.index ["user_id"], :name => "index_evaluations_on_user_id"
  end

  create_table "revisions", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__revisions_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_revisions_user_id"
  end

  create_table "verifications", force: true do |t|
    t.integer  "answer_id"
    t.integer  "user_id"
    t.integer  "answer_attribute_id"
    t.boolean  "verified"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.index ["answer_attribute_id"], :name => "index_verifications_on_answer_attribute_id"
    t.index ["answer_id"], :name => "index_verifications_on_answer_id"
    t.index ["question_id"], :name => "index_verifications_on_question_id"
    t.index ["user_id"], :name => "index_verifications_on_user_id"
  end

end
