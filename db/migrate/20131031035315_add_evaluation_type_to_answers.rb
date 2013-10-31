class AddEvaluationTypeToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :evalution_type, :string, :default=>"default"
  end
end
