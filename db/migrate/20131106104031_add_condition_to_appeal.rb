class AddConditionToAppeal < ActiveRecord::Migration
  def change
    add_column :appeals, :experimental_condition, :string
  end
end
