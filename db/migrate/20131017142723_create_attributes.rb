class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.boolean :is_correct
      t.float :score
      t.belongs_to :question, index: true

      t.timestamps
    end
  end
end
