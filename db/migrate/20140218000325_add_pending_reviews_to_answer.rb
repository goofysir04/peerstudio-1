class AddPendingReviewsToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :pending_reviews, :integer, default: 0
  end
end
