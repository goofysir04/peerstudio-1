class CreateFeedbackPreferences < ActiveRecord::Migration
  def change
    create_table :feedback_preferences do |t|
      t.belongs_to :answer, index: true
      t.belongs_to :rubric_item, index: true

      t.timestamps
    end
  end
end
