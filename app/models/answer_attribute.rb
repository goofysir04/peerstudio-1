class AnswerAttribute < ActiveRecord::Base
  belongs_to :question
  belongs_to :rubric_item
  has_and_belongs_to_many :feedback_items
end
