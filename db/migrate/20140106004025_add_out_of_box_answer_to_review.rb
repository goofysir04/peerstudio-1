class AddOutOfBoxAnswerToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :out_of_box_answer, :boolean
  end
end
