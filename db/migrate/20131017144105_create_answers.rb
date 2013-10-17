class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :response
      t.belongs_to :question, index: true
      t.belongs_to :user, index: true
      t.float :predicted_score
      t.float :current_score
      t.integer :evaluations_wanted
      t.integer :total_evaluations
      t.float :confidence

      t.timestamps
    end
  end
end
