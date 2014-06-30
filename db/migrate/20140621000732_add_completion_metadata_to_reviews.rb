class AddCompletionMetadataToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :completion_metadata, :text
  end
end
