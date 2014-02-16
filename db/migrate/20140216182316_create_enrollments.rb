class CreateEnrollments < ActiveRecord::Migration
	def up
		create_table :enrollments do |t|
			t.references :user
			t.references :course
			t.timestamps
		end


	end

	def down
		drop_table :enrollments
	end
end
