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

ActiveRecord::Schema.define(version: 20131201030318) do

  create_table "answer_attributes", force: true do |t|
    t.boolean  "is_correct"
    t.float    "score"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.index ["question_id"], :name => "index_answer_attributes_on_question_id"
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
    t.index ["assessment_id"], :name => "index_evaluations_on_assessment_id"
    t.index ["answer_attribute_id"], :name => "index_evaluations_on_answer_attribute_id"
    t.index ["user_id"], :name => "index_evaluations_on_user_id"
    t.index ["answer_id"], :name => "index_evaluations_on_answer_id"
    t.index ["question_id"], :name => "index_evaluations_on_question_id"
  end

  create_view "answer_grades", "SELECT answer_id,\n             sum(answer_score) AS final_score,\n             avg(answer_score) AS avg_final_score\n      FROM\n        (SELECT answer_attributes.score AS answer_score,\n                verified_answers.answer_id\n         FROM answer_attributes,\n           (SELECT answer_id,\n                   answer_attribute_id,\n                   id,\n                   assessment_id\n            FROM evaluations\n            WHERE verified_true_count >verified_false_count\n              AND verified_true_count > 0) AS verified_answers\n         WHERE verified_answers.answer_attribute_id = answer_attributes.id) AS answer_scores,\n           answers\n      WHERE answer_scores.answer_id = answers.id\n      GROUP BY answer_scores.answer_id", :force => true
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
    t.index ["user_id"], :name => "index_answers_on_user_id"
    t.index ["question_id"], :name => "index_answers_on_question_id"
  end

  create_table "questions", force: true do |t|
    t.text     "title"
    t.text     "explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "min_score",            default: 0.0
    t.float    "max_score",            default: 1.0
    t.text     "baseline_explanation"
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
    t.index ["answer_id"], :name => "index_appeals_on_answer_id"
    t.index ["answer_id"], :name => "fk__appeals_answer_id"
    t.index ["question_id"], :name => "index_appeals_on_question_id"
    t.index ["question_id"], :name => "fk__appeals_question_id"
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
    t.index ["question_id"], :name => "index_assessments_on_question_id"
    t.index ["answer_id"], :name => "index_assessments_on_answer_id"
    t.index ["user_id"], :name => "index_assessments_on_user_id"
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
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    t.index ["email"], :name => "index_users_on_email", :unique => true
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
    t.index ["question_id"], :name => "index_verifications_on_question_id"
    t.index ["answer_attribute_id"], :name => "index_verifications_on_answer_attribute_id"
    t.index ["user_id"], :name => "index_verifications_on_user_id"
    t.index ["answer_id"], :name => "index_verifications_on_answer_id"
  end

end
