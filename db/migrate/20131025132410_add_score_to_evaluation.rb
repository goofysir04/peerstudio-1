class AddScoreToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :score, :integer, default: nil
  end
end
