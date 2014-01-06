class AddStarredToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :starred, :boolean, default:false
  end
end
