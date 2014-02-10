class AddTypeToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :review_type, :string, default: nil
  end
end
