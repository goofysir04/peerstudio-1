class AddRatedFlagToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :rating_completed, :boolean, default: false
  end
end
