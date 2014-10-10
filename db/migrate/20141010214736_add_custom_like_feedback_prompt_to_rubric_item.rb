class AddCustomLikeFeedbackPromptToRubricItem < ActiveRecord::Migration
  def change
    add_column :rubric_items, :like_feedback_prompt, :text
  end
end
