class FeedbackItem < ActiveRecord::Base
  belongs_to :review
  belongs_to :rubric_item
end
