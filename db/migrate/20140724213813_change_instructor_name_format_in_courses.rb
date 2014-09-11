class ChangeInstructorNameFormatInCourses < ActiveRecord::Migration
  def change
  	change_column :courses, :instructor_name, :text
  end
end
