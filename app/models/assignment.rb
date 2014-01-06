class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :answers
  has_many :rubric_items
  accepts_nested_attributes_for :rubric_items, :allow_destroy => true, reject_if: proc { |attributes| attributes['short_title'].blank? and attributes['title'].blank? }
end
