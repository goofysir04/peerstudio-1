class AddMiscommunicationToRubricItems < ActiveRecord::Migration
  def change
    add_column :rubric_items, :miscommunication, :boolean, :default => false
  end
end
