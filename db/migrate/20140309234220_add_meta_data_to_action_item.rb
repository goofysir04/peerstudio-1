class AddMetaDataToActionItem < ActiveRecord::Migration
  def change
    add_reference :action_items, :review, index: true
    add_reference :action_items, :answer, index: true
    add_column :action_items, :metadata_json, :text
    add_column :action_items, :resolved, :boolean, default: false
    add_column :action_items, :problem, :boolean, default: true
  end
end
