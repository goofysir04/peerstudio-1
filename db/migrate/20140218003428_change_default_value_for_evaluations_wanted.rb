class ChangeDefaultValueForEvaluationsWanted < ActiveRecord::Migration
  def change
  	change_column :answers, :evaluations_wanted, :integer, default: 0
  end
end
