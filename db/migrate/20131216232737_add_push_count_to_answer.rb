class AddPushCountToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :push_count, :integer, :default=>0
  end
end
