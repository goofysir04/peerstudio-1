class CreateTriggerActions < ActiveRecord::Migration
  def change
    create_table :trigger_actions do |t|
      t.string :trigger
      t.string :description
      t.integer :count, default: 0
      t.belongs_to :user, index: true
      t.belongs_to :assignment, index: true

      t.timestamps
    end
  end
end
