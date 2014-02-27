class MakeTotalEvaluationsZeroByDefaultForAnswers < ActiveRecord::Migration
  def change
  	change_column :answers, :total_evaluations, :integer, :default=>0
  end
end
