class AddPriorityToActionItem < ActiveRecord::Migration
  def change
    add_column :action_items, :priority, :integer, default: 0
  end
end
