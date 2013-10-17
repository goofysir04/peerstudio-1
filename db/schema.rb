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

ActiveRecord::Schema.define(version: 20131017144105) do

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
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id"
  add_index "answers", ["user_id"], name: "index_answers_on_user_id"

  create_table "attributes", force: true do |t|
    t.boolean  "is_correct"
    t.float    "score"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attributes", ["question_id"], name: "index_attributes_on_question_id"

  create_table "evaluations", force: true do |t|
    t.integer  "question_id"
    t.integer  "answer_id"
    t.text     "reason"
    t.integer  "attribute_id"
    t.integer  "verified_true_count",  default: 0
    t.integer  "verified_false_count", default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evaluations", ["answer_id"], name: "index_evaluations_on_answer_id"
  add_index "evaluations", ["attribute_id"], name: "index_evaluations_on_attribute_id"
  add_index "evaluations", ["question_id"], name: "index_evaluations_on_question_id"
  add_index "evaluations", ["user_id"], name: "index_evaluations_on_user_id"

  create_table "questions", force: true do |t|
    t.text     "title"
    t.text     "explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "min_score",   default: 0.0
    t.float    "max_score",   default: 1.0
  end

end
