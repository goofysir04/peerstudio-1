class AddActiveFlagToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :active, :boolean, default: true
  end
end
