class AddRubricItemIdToAnswerAttribute < ActiveRecord::Migration
  def change
    add_reference :answer_attributes, :rubric_item
  end
end
