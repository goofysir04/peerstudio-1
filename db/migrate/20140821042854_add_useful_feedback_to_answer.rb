class AddUsefulFeedbackToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :useful_feedback, :boolean
  end
end
