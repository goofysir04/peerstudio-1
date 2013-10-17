class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.belongs_to :question, index: true
      t.belongs_to :answer, index: true
      t.text :reason
      t.belongs_to :attribute, index: true
      t.integer :verified_true_count, :default => 0
      t.integer :verified_false_count, :default => 0
      t.belongs_to :user, index: true
      
      t.timestamps
    end
  end
end
