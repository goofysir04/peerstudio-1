class CreateAssignmentGrades < ActiveRecord::Migration
  def change
    create_table :assignment_grades do |t|
      t.belongs_to :assignment, index: true
      t.belongs_to :user, index: true
      t.belongs_to :rubric_item, index: true
      t.string :grade_type

      t.timestamps
    end
  end
end
