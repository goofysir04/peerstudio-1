class CreateActionItems < ActiveRecord::Migration
  def change
    create_table :action_items do |t|
      t.belongs_to :user, index: true
      t.belongs_to :assignment, index: true
      t.text :reason
      t.string :reason_code
      t.text :action
      t.timestamps
    end
  end
end
