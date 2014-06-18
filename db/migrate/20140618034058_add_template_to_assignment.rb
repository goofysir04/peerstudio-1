class AddTemplateToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :template, :text
  end
end
