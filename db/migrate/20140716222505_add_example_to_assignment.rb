class AddExampleToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :example, :text
  end
end
