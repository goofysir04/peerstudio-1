class AddIdToFeedbackItemAttribute < ActiveRecord::Migration
  def change
    add_column :feedback_item_attributes, :id, :primary_key
  end
end
