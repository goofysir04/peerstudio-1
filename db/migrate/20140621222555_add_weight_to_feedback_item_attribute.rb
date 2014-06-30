class AddWeightToFeedbackItemAttribute < ActiveRecord::Migration
  def change
    add_column :feedback_item_attributes, :weight, :float, default: 1.0
  end
end
