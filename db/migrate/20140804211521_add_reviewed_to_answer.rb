class AddReviewedToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :review_completed, :boolean, default: false
  end
end
