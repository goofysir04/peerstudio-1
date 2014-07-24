class AddInstructorNameToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :instructor_name, :string
  end
end
