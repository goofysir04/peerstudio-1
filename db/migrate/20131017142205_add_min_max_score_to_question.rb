class AddMinMaxScoreToQuestion < ActiveRecord::Migration
  def change
  	add_column :questions, :min_score, :float, :default => 0
  	add_column :questions, :max_score, :float, :default => 1
  end
end
