class AddHasOptedOutHelpEmailToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :has_opted_out_help_email, :boolean, :default => false
  end
end
