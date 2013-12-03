class AddAnswerTypeToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :answer_type, :string
  end
end
