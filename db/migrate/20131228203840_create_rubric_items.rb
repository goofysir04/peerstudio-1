class CreateRubricItems < ActiveRecord::Migration
  def change
    create_table :rubric_items do |t|
      t.text :title
      t.string :short_title
      t.datetime :ends_at
      t.boolean :final_only, :default=> false
      t.float :min, default: 0
      t.float :max
      t.string :min_label
      t.string :max_label
      t.belongs_to :assignment, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
