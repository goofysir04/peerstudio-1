class AssignmentGrade < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  belongs_to :rubric_item
end
