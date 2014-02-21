class AddRatingCommentsToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :other_rating_comments, :text
  end
end
