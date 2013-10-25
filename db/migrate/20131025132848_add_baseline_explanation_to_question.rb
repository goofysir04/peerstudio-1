class AddBaselineExplanationToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :baseline_explanation, :text
  end
end
