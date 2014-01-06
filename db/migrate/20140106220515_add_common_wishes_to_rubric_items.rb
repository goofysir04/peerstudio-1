class AddCommonWishesToRubricItems < ActiveRecord::Migration
  def change
    add_column :rubric_items, :common_wishes, :text
  end
end
