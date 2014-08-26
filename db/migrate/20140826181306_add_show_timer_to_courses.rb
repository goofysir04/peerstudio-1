class AddShowTimerToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :show_timer, :boolean, default: true
  end
end
