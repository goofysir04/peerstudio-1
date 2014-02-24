class AddMarkedAndTotalReviewsToAssignmentGrade < ActiveRecord::Migration
  def change
    add_column :assignment_grades, :marked_reviews, :integer, default: 0
    add_column :assignment_grades, :total_reviews, :integer, default: 0
  end
end
