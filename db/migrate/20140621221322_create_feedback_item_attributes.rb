class CreateFeedbackItemAttributes < ActiveRecord::Migration
  def change
  	change_table :feedback_item_attributes do |t|
  		t.timestamps
  	end
  end
end
