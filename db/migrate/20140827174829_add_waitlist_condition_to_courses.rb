class AddWaitlistConditionToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :waitlist_condition, :boolean, default: false
  end
end
