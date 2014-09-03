class ChangeAssignmentGradeCreditToDecimal < ActiveRecord::Migration
  def change
  	change_column :assignment_grades, :credit, :decimal, scale: 3, precision: 5
  end
end
