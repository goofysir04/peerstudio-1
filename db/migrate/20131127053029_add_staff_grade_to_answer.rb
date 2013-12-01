class AddStaffGradeToAnswer < ActiveRecord::Migration
  def change
  	add_column :answers, :staff_graded, :boolean, default: false
  end
end
