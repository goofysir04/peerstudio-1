class AddExampleToAnswerAttribute < ActiveRecord::Migration
  def change
    add_column :answer_attributes, :example, :text
  end
end
