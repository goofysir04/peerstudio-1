class AddCreditToAssignmentGrades < ActiveRecord::Migration
  def change
    add_column :assignment_grades, :credit, :float, default: 0.0
  end
end
