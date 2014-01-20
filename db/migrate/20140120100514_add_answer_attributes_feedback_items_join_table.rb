class AddAnswerAttributesFeedbackItemsJoinTable < ActiveRecord::Migration
  def change
  	create_table :answer_attributes_feedback_items, :id => false do |t|
      t.integer :answer_attribute_id
      t.integer :feedback_item_id
    end
  end
end
