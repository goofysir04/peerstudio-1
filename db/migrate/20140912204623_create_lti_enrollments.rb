class CreateLtiEnrollments < ActiveRecord::Migration
  def change
    create_table :lti_enrollments do |t|
      t.belongs_to :user, index: true
      t.belongs_to :assignment, index: true
      t.text :lti_user_id
      t.text :lis_result_sourcedid
      t.text :lis_outcome_service_url

      t.timestamps
    end
  end
end
