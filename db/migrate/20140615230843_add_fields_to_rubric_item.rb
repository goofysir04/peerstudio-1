class AddFieldsToRubricItem < ActiveRecord::Migration
  def change
    add_column :rubric_items, :show_for_feedback, :boolean, default: true
    add_column :rubric_items, :show_for_final, :boolean, default: true
    add_column :rubric_items, :show_as_radio, :boolean, default: false
  end
end
