class CreateAppeals < ActiveRecord::Migration
  def change
    create_table :appeals do |t|
      t.text :comments
      t.belongs_to :question, index: true
      t.belongs_to :answer, index: true
      t.boolean :accepted
      t.boolean :inspected
      t.float :appeal_score

      t.timestamps
    end
  end
end
