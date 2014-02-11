class AddOpenAtToRubricItems < ActiveRecord::Migration
  def change
  	add_column :rubric_items, :open_at, :datetime
  end
end
