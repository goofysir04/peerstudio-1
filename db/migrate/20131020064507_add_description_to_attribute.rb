class AddDescriptionToAttribute < ActiveRecord::Migration
  def change
  	add_column :attributes, :description, :text
  end
end
