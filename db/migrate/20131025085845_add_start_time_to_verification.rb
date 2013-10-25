class AddStartTimeToVerification < ActiveRecord::Migration
  def change
    add_column :verifications, :started_at, :datetime
  end
end
