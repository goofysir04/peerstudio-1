class RemoveInProgressInAnswers < ActiveRecord::Migration
  def change
  	remove_column :answers, :in_progress
  end
end
