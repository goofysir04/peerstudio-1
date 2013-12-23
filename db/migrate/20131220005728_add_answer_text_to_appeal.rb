class AddAnswerTextToAppeal < ActiveRecord::Migration
  def change
    add_column :appeals, :answer_text, :text
  end
end
