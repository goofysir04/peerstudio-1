class ChangeAssignmentGradeCreditToDecimal < ActiveRecord::Migration
  def change
  	change_column :assignment_grades, :credit, :decimal, precision: 4, scale: 3
  end
end
