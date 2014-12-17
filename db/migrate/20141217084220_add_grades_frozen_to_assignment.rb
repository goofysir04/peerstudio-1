class AddGradesFrozenToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :grades_frozen, :boolean, default: false
  end
end
