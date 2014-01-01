class CreateFeedbackItems < ActiveRecord::Migration
  def change
    create_table :feedback_items do |t|
      t.belongs_to :review, index: true
      t.belongs_to :rubric_item, index: true
      t.text :like_feedback
      t.text :wish_feedback
      t.float :score

      t.timestamps
    end
  end
end
