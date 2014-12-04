class RemoveAppeal < ActiveRecord::Migration
  def up
    execute "DROP TABLE appeals CASCADE"
  end

  def down
    create_table :appeals do |t|
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
  end
end
