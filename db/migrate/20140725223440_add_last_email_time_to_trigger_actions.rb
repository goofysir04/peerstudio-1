class AddLastEmailTimeToTriggerActions < ActiveRecord::Migration
  def change
  	add_column :trigger_actions, :last_email_time, :datetime
  end
end
