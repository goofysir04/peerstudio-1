class AddSubmittedAtToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers, :submitted_at, :datetime
  end
end
