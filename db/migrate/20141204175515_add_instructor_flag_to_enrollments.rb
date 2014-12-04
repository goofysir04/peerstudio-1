class AddInstructorFlagToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :instructor, :boolean, default: false
  end
end
