class AddMiscommunicationToFeedbackItems < ActiveRecord::Migration
  def change
    add_column :feedback_items, :miscommunication, :boolean
  end
end
