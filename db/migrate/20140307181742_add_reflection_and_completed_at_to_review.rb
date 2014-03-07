class AddReflectionAndCompletedAtToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :reflection, :text
    add_column :reviews, :completed_at, :datetime
  end
end
