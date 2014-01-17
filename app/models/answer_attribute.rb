class AnswerAttribute < ActiveRecord::Base
  belongs_to :question
  belongs_to :rubric_item
end
