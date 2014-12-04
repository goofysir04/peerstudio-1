class RemoveQuestion < ActiveRecord::Migration

  def up
    execute "DROP TABLE questions CASCADE"
  end

  def down
    create_table :questions do |t|
      t.text     "title"
      t.text     "explanation"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.float    "min_score",                default: 0.0
      t.float    "max_score",                default: 1.0
      t.text     "baseline_explanation"
      t.string   "score_aggregation_method", default: "sum"
    end
  end
end
