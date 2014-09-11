class AddReviewMethodToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :review_method, :string, default: "normal"
  end
end
