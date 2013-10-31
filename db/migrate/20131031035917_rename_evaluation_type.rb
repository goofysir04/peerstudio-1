class RenameEvaluationType < ActiveRecord::Migration
  def change
  	rename_column :answers, :evalution_type, :evaluation_type
  end
end
