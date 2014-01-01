class Review < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  belongs_to :assignment
  has_many :feedback_items

  accepts_nested_attributes_for :feedback_items, allow_destroy: true
end
