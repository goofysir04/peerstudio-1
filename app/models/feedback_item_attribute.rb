class FeedbackItemAttribute < ActiveRecord::Base
  belongs_to :feedback_item
  belongs_to :answer_attribute
end
