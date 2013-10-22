class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.belongs_to :user, index: true
      t.belongs_to :answer, index: true
      t.text :comments
      t.belongs_to :question, index: true

      t.timestamps
    end
  end
end
