class AddOpenAndCloseToTaggings < ActiveRecord::Migration
  def change
  	add_column :taggings, :open_at, :datetime
  	add_column :taggings, :close_at, :datetime
  	add_column :taggings, :review_open_at, :datetime
  	add_column :taggings, :review_close_at, :datetime
  end
end
