class AddScoreAggregationMethodToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :score_aggregation_method, :string, :default=>"sum"
  end
end
