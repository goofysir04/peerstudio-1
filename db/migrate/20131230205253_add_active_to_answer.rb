class AddActiveToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :active, :boolean, default: true
  end
end
