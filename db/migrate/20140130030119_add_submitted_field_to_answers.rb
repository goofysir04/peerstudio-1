class AddSubmittedFieldToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :submitted, :boolean, default: false
  end
end
