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

ActiveRecord::Schema.define(version: 20140120111722) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
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
    t.index ["user_id"], :name => "index_courses_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_courses_user_id"
  end

  create_table "assignments", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "due_at"
    t.datetime "open_at"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["course_id"], :name => "index_assignments_on_course_id"
    t.index ["user_id"], :name => "index_assignments_on_user_id"
    t.foreign_key ["course_id"], "courses", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_assignments_course_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_assignments_user_id"
  end

  create_table "rubric_items", force: true do |t|
    t.text     "title"
    t.string   "short_title"
    t.datetime "ends_at"
    t.boolean  "final_only",    default: false
    t.float    "min",           default: 0.0
    t.float    "max"
    t.string   "min_label"
    t.string   "max_label"
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "common_wishes"
    t.index ["assignment_id"], :name => "index_rubric_items_on_assignment_id"
    t.index ["user_id"], :name => "index_rubric_items_on_user_id"
    t.foreign_key ["assignment_id"], "assignments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_rubric_items_assignment_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_rubric_items_user_id"
  end

  create_table "answer_attributes", force: true do |t|
    t.boolean  "is_correct"
    t.float    "score"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "rubric_item_id"
    t.index ["rubric_item_id"], :name => "fk__answer_attributes_rubric_item_id"
    t.index ["question_id"], :name => "index_answer_attributes_on_question_id"
    t.foreign_key ["rubric_item_id"], "rubric_items", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_answer_attributes_rubric_item_id"
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
    t.string   "base_revision_name"
    t.integer  "assignment_id"
    t.boolean  "active",             default: true
    t.boolean  "starred",            default: false
    t.index ["assignment_id"], :name => "fk__answers_assignment_id"
    t.index ["question_id"], :name => "index_answers_on_question_id"
    t.index ["user_id"], :name => "index_answers_on_user_id"
    t.foreign_key ["assignment_id"], "assignments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_answers_assignment_id"
  end

  create_table "reviews", force: true do |t|
    t.integer  "answer_id"
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "out_of_box_answer"
    t.index ["answer_id"], :name => "index_reviews_on_answer_id"
    t.index ["assignment_id"], :name => "index_reviews_on_assignment_id"
    t.index ["user_id"], :name => "index_reviews_on_user_id"
    t.foreign_key ["answer_id"], "answers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_reviews_answer_id"
    t.foreign_key ["assignment_id"], "assignments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_reviews_assignment_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_reviews_user_id"
  end

  create_table "feedback_items", force: true do |t|
    t.integer  "review_id"
    t.integer  "rubric_item_id"
    t.text     "like_feedback"
    t.text     "wish_feedback"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["review_id"], :name => "index_feedback_items_on_review_id"
    t.index ["rubric_item_id"], :name => "index_feedback_items_on_rubric_item_id"
    t.foreign_key ["review_id"], "reviews", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_feedback_items_review_id"
    t.foreign_key ["rubric_item_id"], "rubric_items", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_feedback_items_rubric_item_id"
  end

  create_table "answer_attributes_feedback_items", id: false, force: true do |t|
    t.integer "answer_attribute_id"
    t.integer "feedback_item_id"
    t.index ["answer_attribute_id"], :name => "fk__answer_attributes_feedback_items_answer_attribute_id"
    t.index ["feedback_item_id"], :name => "fk__answer_attributes_feedback_items_feedback_item_id"
    t.foreign_key ["answer_attribute_id"], "answer_attributes", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_answer_attributes_feedback_items_answer_attribute_id"
    t.foreign_key ["feedback_item_id"], "feedback_items", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_answer_attributes_feedback_items_feedback_item_id"
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
    t.integer  "question_id"
    t.integer  "answer_id"
    t.boolean  "accepted"
    t.boolean  "inspected"
    t.float    "appeal_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "experimental_condition"
    t.text     "instructor_comments"
    t.text     "answer_text"
    t.index ["answer_id"], :name => "index_appeals_on_answer_id"
    t.index ["question_id"], :name => "index_appeals_on_question_id"
    t.foreign_key ["answer_id"], "answers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_appeals_answer_id"
    t.foreign_key ["question_id"], "questions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_appeals_question_id"
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
    t.index ["answer_id"], :name => "index_assessments_on_answer_id"
    t.index ["question_id"], :name => "index_assessments_on_question_id"
    t.index ["user_id"], :name => "index_assessments_on_user_id"
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

  create_table "attributes", force: true do |t|
    t.boolean  "is_correct"
    t.float    "score"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["question_id"], :name => "index_attributes_on_question_id"
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
    t.index ["user_id"], :name => "index_revisions_on_user_id"
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
