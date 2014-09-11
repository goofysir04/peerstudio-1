class AddReviewRequestToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :review_request, :text
  end
end
