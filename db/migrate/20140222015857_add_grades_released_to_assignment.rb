class AddGradesReleasedToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :grades_released, :boolean, default: false
  end
end
