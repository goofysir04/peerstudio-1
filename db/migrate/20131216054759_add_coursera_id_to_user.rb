class AddCourseraIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :cid, :integer
  end
end
