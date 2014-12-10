class AddOverriddenToAssignmentGrade < ActiveRecord::Migration
  def change
    add_column :assignment_grades, :overridden, :boolean, default: false
  end
end
