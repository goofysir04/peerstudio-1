class AddStartTimeToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :started_at, :datetime
  end
end
