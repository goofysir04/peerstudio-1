class AddIsBlankSubmissionToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :is_blank_submission, :boolean, default: false
  end
end
