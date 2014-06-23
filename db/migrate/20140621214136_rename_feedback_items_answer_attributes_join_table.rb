class RenameFeedbackItemsAnswerAttributesJoinTable < ActiveRecord::Migration
  def change
  	rename_table :answer_attributes_feedback_items, :feedback_item_attributes
  end
end
