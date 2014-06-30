class AddAttributeTypeToAnswerAttribute < ActiveRecord::Migration
  def change
    add_column :answer_attributes, :attribute_type, :string, default: "binary"
  end
end
