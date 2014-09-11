class AddEarlyFeedbackOnlyToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :early_feedback_only, :boolean, :default => false
  end
end
