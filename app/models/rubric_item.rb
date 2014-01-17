class RubricItem < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :answer_attributes

  default_scope :order=>'ends_at ASC, created_at ASC'
end
