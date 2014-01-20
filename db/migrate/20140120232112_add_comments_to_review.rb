class AddCommentsToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :comments, :text
  end
end
