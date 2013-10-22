class AddAssessmentRefToEvaluations < ActiveRecord::Migration
  def change
    add_reference :evaluations, :assessment, index: true
  end
end
