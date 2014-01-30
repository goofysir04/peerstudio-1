class RenameSubmittedAnswersToPrivate < ActiveRecord::Migration
  def change
  	rename_column :answers, :submitted, :in_progress
  end
end
