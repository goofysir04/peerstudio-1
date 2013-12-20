class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.text :name
      t.string :image_url
      t.text :institution
      t.boolean :hidden, default: true
      t.boolean :open_enrollment, default: false
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
