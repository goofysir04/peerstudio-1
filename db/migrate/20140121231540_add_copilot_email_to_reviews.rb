class AddCopilotEmailToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :copilot_email, :string
  end
end
