class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :answer, index: true
      t.belongs_to :user, index: true
      t.belongs_to :assignment, index: true

      t.timestamps
    end
  end
end
