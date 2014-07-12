class AddRawLtiParamsToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :raw_lti_params, :text
  end
end
