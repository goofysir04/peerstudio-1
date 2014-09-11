class AddExperimentalGroupToUser < ActiveRecord::Migration
  def change
    add_column :users, :experimental_group, :string
  end
end
