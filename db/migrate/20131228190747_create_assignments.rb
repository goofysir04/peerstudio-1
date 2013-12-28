class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :title
      t.string :description
      t.datetime :due_at
      t.datetime :open_at
      t.belongs_to :user, index: true
      t.belongs_to :course, index: true

      t.timestamps
    end
  end
end
