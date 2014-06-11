class AddIsFinalToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :is_final, :boolean, default: false
  end
end
