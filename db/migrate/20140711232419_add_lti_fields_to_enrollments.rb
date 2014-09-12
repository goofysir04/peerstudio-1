class AddLtiFieldsToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :lis_result_sourcedid, :string
    add_column :enrollments, :lti_user_id, :string
    add_column :enrollments, :roles, :string
  end
end
