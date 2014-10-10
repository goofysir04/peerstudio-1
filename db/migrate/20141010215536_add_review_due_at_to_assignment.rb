class AddReviewDueAtToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :review_due_at, :datetime
  end
end
