class FeedbackItem < ActiveRecord::Base
  belongs_to :review
  belongs_to :rubric_item
  has_and_belongs_to_many :answer_attributes
end
