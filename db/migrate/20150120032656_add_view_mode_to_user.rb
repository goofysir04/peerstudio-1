class AddViewModeToUser < ActiveRecord::Migration
  def change
    add_column :users, :view_mode, :string
  end
end
