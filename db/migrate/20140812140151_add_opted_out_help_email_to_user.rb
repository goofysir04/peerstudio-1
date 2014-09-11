class AddOptedOutHelpEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :opted_out_help_email, :boolean, default: false
  end
end
