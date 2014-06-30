class FeedbackItem < ActiveRecord::Base
  belongs_to :review
  belongs_to :rubric_item
  has_many :answer_attributes, through: :feedback_item_attributes
  has_many :feedback_item_attributes
end

