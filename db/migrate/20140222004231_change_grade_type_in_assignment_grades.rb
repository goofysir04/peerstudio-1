class ChangeGradeTypeInAssignmentGrades < ActiveRecord::Migration
  def change
  	change_column :assignment_grades, :grade_type, :text
  end
end
