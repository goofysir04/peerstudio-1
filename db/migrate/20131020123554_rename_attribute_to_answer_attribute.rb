class RenameAttributeToAnswerAttribute < ActiveRecord::Migration
  def change
  	rename_table :attributes, :answer_attributes
  	rename_column :evaluations, :attribute_id, :answer_attribute_id
  end
end
