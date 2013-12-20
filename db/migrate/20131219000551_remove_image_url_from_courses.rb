class RemoveImageUrlFromCourses < ActiveRecord::Migration
  def change
  	remove_column :courses, :image_url
  end
end
