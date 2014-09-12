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

ActiveRecord::Schema.define(version: 20140912204623) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.text     "reason"
    t.string   "reason_code"
    t.text     "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "review_id"
    t.integer  "answer_id"
    t.text     "metadata_json"
    t.boolean  "resolved",      default: false
    t.boolean  "problem",       default: true
    t.integer  "priority",      default: 0
  end

  add_index "action_items", ["answer_id"], name: "index_action_items_on_answer_id", using: :btree
  add_index "action_items", ["assignment_id"], name: "fk__action_items_assignment_id", using: :btree
  add_index "action_items", ["assignment_id"], name: "index_action_items_on_assignment_id", using: :btree
  add_index "action_items", ["review_id"], name: "index_action_items_on_review_id", using: :btree
  add_index "action_items", ["user_id"], name: "fk__action_items_user_id", using: :btree
  add_index "action_items", ["user_id"], name: "index_action_items_on_user_id", using: :btree

  create_table "answer_attributes", force: true do |t|
    t.boolean  "is_correct"
    t.float    "score"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "rubric_item_id"
    t.string   "attribute_type", default: "binary"
    t.text     "example"
  end

  add_index "answer_attributes", ["question_id"], name: "index_answer_attributes_on_question_id", using: :btree
  add_index "answer_attributes", ["rubric_item_id"], name: "fk__answer_attributes_rubric_item_id", using: :btree

  create_table "answers", force: true do |t|
    t.text     "response"
    t.integer  "question_id"
    t.integer  "user_id"
    t.float    "predicted_score"
    t.float    "current_score"
    t.integer  "evaluations_wanted",    default: 0
    t.integer  "total_evaluations",     default: 0
    t.float    "confidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                 default: "identify"
    t.string   "evaluation_type",       default: "default"
    t.boolean  "staff_graded",          default: false
    t.integer  "push_count",            default: 0
    t.string   "base_revision_name"
    t.integer  "assignment_id"
    t.boolean  "active",                default: true
    t.boolean  "starred",               default: false
    t.integer  "pending_reviews",       default: 0
    t.boolean  "submitted",             default: false
    t.boolean  "is_final",              default: false
    t.integer  "previous_version_id"
    t.text     "reflection"
    t.datetime "submitted_at"
    t.boolean  "review_completed",      default: false
    t.text     "review_request"
    t.boolean  "is_blank_submission",   default: false
    t.boolean  "revision_email_sent",   default: false
    t.boolean  "useful_feedback"
    t.datetime "reviews_first_seen_at"
  end

  add_index "answers", ["assignment_id"], name: "fk__answers_assignment_id", using: :btree
  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

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
  end

  add_index "appeals", ["answer_id"], name: "fk__appeals_answer_id", using: :btree
  add_index "appeals", ["answer_id"], name: "index_appeals_on_answer_id", using: :btree
  add_index "appeals", ["question_id"], name: "fk__appeals_question_id", using: :btree
  add_index "appeals", ["question_id"], name: "index_appeals_on_question_id", using: :btree

  create_table "assessments", force: true do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.text     "comments"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.string   "answer_type"
  end

  add_index "assessments", ["answer_id"], name: "index_assessments_on_answer_id", using: :btree
  add_index "assessments", ["question_id"], name: "index_assessments_on_question_id", using: :btree
  add_index "assessments", ["user_id"], name: "index_assessments_on_user_id", using: :btree

  create_table "assignment_grades", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.integer  "rubric_item_id"
    t.text     "grade_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credit",         default: 0.0
    t.integer  "marked_reviews", default: 0
    t.integer  "total_reviews",  default: 0
  end

  add_index "assignment_grades", ["assignment_id"], name: "fk__assignment_grades_assignment_id", using: :btree
  add_index "assignment_grades", ["assignment_id"], name: "index_assignment_grades_on_assignment_id", using: :btree
  add_index "assignment_grades", ["rubric_item_id"], name: "fk__assignment_grades_rubric_item_id", using: :btree
  add_index "assignment_grades", ["rubric_item_id"], name: "index_assignment_grades_on_rubric_item_id", using: :btree
  add_index "assignment_grades", ["user_id"], name: "fk__assignment_grades_user_id", using: :btree
  add_index "assignment_grades", ["user_id"], name: "index_assignment_grades_on_user_id", using: :btree

  create_table "assignments", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "due_at"
    t.datetime "open_at"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "grades_released", default: false
    t.text     "template"
    t.text     "example"
  end

  add_index "assignments", ["course_id"], name: "fk__assignments_course_id", using: :btree
  add_index "assignments", ["course_id"], name: "index_assignments_on_course_id", using: :btree
  add_index "assignments", ["user_id"], name: "fk__assignments_user_id", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "attached_assets", force: true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.boolean  "deleted",            default: false
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
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id_"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id_"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "courses", force: true do |t|
    t.text     "title"
    t.text     "institution"
    t.boolean  "hidden",              default: true
    t.boolean  "open_enrollment",     default: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.text     "forum_link"
    t.text     "consumer_key"
    t.text     "consumer_secret"
    t.text     "instructor_name"
    t.boolean  "early_feedback_only", default: false
    t.boolean  "show_timer",          default: true
    t.boolean  "waitlist_condition",  default: false
  end

  add_index "courses", ["user_id"], name: "fk__courses_user_id", using: :btree
  add_index "courses", ["user_id"], name: "index_courses_on_user_id", using: :btree

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
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "enrollments", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lis_result_sourcedid"
    t.string   "lti_user_id"
    t.string   "roles"
    t.text     "raw_lti_params"
  end

  add_index "enrollments", ["course_id"], name: "fk__enrollments_course_id", using: :btree
  add_index "enrollments", ["user_id"], name: "fk__enrollments_user_id", using: :btree

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
  end

  add_index "evaluations", ["answer_attribute_id"], name: "index_evaluations_on_answer_attribute_id", using: :btree
  add_index "evaluations", ["answer_id"], name: "index_evaluations_on_answer_id", using: :btree
  add_index "evaluations", ["assessment_id"], name: "index_evaluations_on_assessment_id", using: :btree
  add_index "evaluations", ["question_id"], name: "index_evaluations_on_question_id", using: :btree
  add_index "evaluations", ["user_id"], name: "index_evaluations_on_user_id", using: :btree

  create_table "feedback_item_attributes", force: true do |t|
    t.integer  "answer_attribute_id"
    t.integer  "feedback_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "weight",              default: 1.0
  end

  add_index "feedback_item_attributes", ["answer_attribute_id"], name: "fk__answer_attributes_feedback_items_answer_attribute_id", using: :btree
  add_index "feedback_item_attributes", ["feedback_item_id"], name: "fk__answer_attributes_feedback_items_feedback_item_id", using: :btree

  create_table "feedback_items", force: true do |t|
    t.integer  "review_id"
    t.integer  "rubric_item_id"
    t.text     "like_feedback"
    t.text     "wish_feedback"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "miscommunication", default: false
  end

  add_index "feedback_items", ["review_id"], name: "fk__feedback_items_review_id", using: :btree
  add_index "feedback_items", ["review_id"], name: "index_feedback_items_on_review_id", using: :btree
  add_index "feedback_items", ["rubric_item_id"], name: "fk__feedback_items_rubric_item_id", using: :btree
  add_index "feedback_items", ["rubric_item_id"], name: "index_feedback_items_on_rubric_item_id", using: :btree

  create_table "feedback_preferences", force: true do |t|
    t.integer  "answer_id"
    t.integer  "rubric_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback_preferences", ["answer_id"], name: "index_feedback_preferences_on_answer_id", using: :btree
  add_index "feedback_preferences", ["rubric_item_id"], name: "index_feedback_preferences_on_rubric_item_id", using: :btree

  create_table "lti_enrollments", force: true do |t|
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.text     "lti_user_id"
    t.text     "lis_result_sourcedid"
    t.text     "lis_outcome_service_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lti_enrollments", ["assignment_id"], name: "index_lti_enrollments_on_assignment_id", using: :btree
  add_index "lti_enrollments", ["user_id"], name: "index_lti_enrollments_on_user_id", using: :btree

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

  create_table "reviews", force: true do |t|
    t.integer  "answer_id"
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "out_of_box_answer"
    t.text     "comments"
    t.string   "copilot_email"
    t.string   "review_type"
    t.boolean  "active",                default: true
    t.integer  "accurate_rating"
    t.integer  "concrete_rating"
    t.integer  "recognize_rating"
    t.text     "other_rating_comments"
    t.boolean  "rating_completed",      default: false
    t.text     "reflection"
    t.datetime "completed_at"
    t.text     "completion_metadata"
    t.string   "review_method",         default: "normal"
  end

  add_index "reviews", ["answer_id"], name: "fk__reviews_answer_id", using: :btree
  add_index "reviews", ["answer_id"], name: "index_reviews_on_answer_id", using: :btree
  add_index "reviews", ["assignment_id"], name: "fk__reviews_assignment_id", using: :btree
  add_index "reviews", ["assignment_id"], name: "index_reviews_on_assignment_id", using: :btree
  add_index "reviews", ["user_id"], name: "fk__reviews_user_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "revisions", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revisions", ["user_id"], name: "fk__revisions_user_id", using: :btree
  add_index "revisions", ["user_id"], name: "index_revisions_on_user_id", using: :btree

  create_table "rubric_items", force: true do |t|
    t.text     "title"
    t.string   "short_title"
    t.datetime "ends_at"
    t.boolean  "final_only",        default: false
    t.float    "min",               default: 0.0
    t.float    "max"
    t.string   "min_label"
    t.string   "max_label"
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "common_wishes"
    t.datetime "open_at"
    t.boolean  "show_for_feedback", default: true
    t.boolean  "show_for_final",    default: true
    t.boolean  "show_as_radio",     default: false
  end

  add_index "rubric_items", ["assignment_id"], name: "fk__rubric_items_assignment_id", using: :btree
  add_index "rubric_items", ["assignment_id"], name: "index_rubric_items_on_assignment_id", using: :btree
  add_index "rubric_items", ["user_id"], name: "fk__rubric_items_user_id", using: :btree
  add_index "rubric_items", ["user_id"], name: "index_rubric_items_on_user_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",         limit: 128
    t.datetime "created_at"
    t.datetime "open_at"
    t.datetime "close_at"
    t.datetime "review_open_at"
    t.datetime "review_close_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "fk__taggings_tag_id", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "trigger_actions", force: true do |t|
    t.string   "trigger"
    t.string   "description"
    t.integer  "count",           default: 0
    t.integer  "user_id"
    t.integer  "assignment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_email_time"
  end

  add_index "trigger_actions", ["assignment_id"], name: "index_trigger_actions_on_assignment_id", using: :btree
  add_index "trigger_actions", ["user_id"], name: "index_trigger_actions_on_user_id", using: :btree

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
    t.integer  "cid"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "consented"
    t.boolean  "admin",                  default: false
    t.boolean  "opted_out_help_email",   default: false
    t.string   "experimental_group"
    t.boolean  "tried_answering"
    t.boolean  "tried_reviewing"
    t.text     "unsubscribe_reason"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "verifications", force: true do |t|
    t.integer  "answer_id"
    t.integer  "user_id"
    t.integer  "answer_attribute_id"
    t.boolean  "verified"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
  end

  add_index "verifications", ["answer_attribute_id"], name: "index_verifications_on_answer_attribute_id", using: :btree
  add_index "verifications", ["answer_id"], name: "index_verifications_on_answer_id", using: :btree
  add_index "verifications", ["question_id"], name: "index_verifications_on_question_id", using: :btree
  add_index "verifications", ["user_id"], name: "index_verifications_on_user_id", using: :btree

end
