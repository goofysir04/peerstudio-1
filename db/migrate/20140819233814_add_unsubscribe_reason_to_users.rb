class AddUnsubscribeReasonToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :unsubscribe_reason, :text
  end
end
