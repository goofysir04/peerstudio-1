class AddReflectionToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :reflection, :text
  end
end
