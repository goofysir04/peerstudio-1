class AddReviewsFirstSeenAtToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :reviews_first_seen_at, :datetime
  end
end
