class AddExperimentalFlagToAssignmentGrade < ActiveRecord::Migration
  def change
    add_column :assignment_grades, :experimental, :boolean, default: false
    add_column :assignment_grades, :source, :string, default: "peer"
  end
end
