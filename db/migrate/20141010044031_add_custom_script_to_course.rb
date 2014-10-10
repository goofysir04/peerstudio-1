class AddCustomScriptToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :custom_script, :text
  end
end
