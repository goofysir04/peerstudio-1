class AddAnswerToAssignmentGrade < ActiveRecord::Migration
  def change
    add_reference :assignment_grades, :answer, index: true
    add_column :assignment_grades, :is_final, :boolean, default: true
  end
end
