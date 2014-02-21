class AddRatingColumnsToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :accurate_rating, :integer
    add_column :reviews, :concrete_rating, :integer
    add_column :reviews, :recognize_rating, :integer
  end
end
