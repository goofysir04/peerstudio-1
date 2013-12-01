class AddInstructorCommentsToAppeals < ActiveRecord::Migration
  def change
    add_column :appeals, :instructor_comments, :text
  end
end
