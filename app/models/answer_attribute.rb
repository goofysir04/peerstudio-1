class AnswerAttribute < ActiveRecord::Base
  belongs_to :question
  belongs_to :rubric_item
  has_many :feedback_item_attributes
  has_many :feedback_items, through: :feedback_item_attributes

end
