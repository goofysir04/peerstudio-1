class RemoveReasonFromEvaluation < ActiveRecord::Migration
  def change
  	remove_column :evaluations, :reason
  end
end
