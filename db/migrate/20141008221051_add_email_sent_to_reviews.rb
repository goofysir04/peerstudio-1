class AddEmailSentToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :email_sent, :boolean
  end
end
