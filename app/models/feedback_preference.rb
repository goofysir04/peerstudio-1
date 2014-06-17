class FeedbackPreference < ActiveRecord::Base
  belongs_to :answer
  belongs_to :rubric_item
end
