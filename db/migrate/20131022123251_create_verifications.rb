class CreateVerifications < ActiveRecord::Migration
  def change
    create_table :verifications do |t|
      t.belongs_to :answer, index: true
      t.belongs_to :user, index: true
      t.belongs_to :answer_attribute, index: true
      t.boolean :verified
      t.belongs_to :question, index: true

      t.timestamps
    end
  end
end
