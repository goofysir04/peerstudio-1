class RubricItem < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :answer_attributes, :dependent => :destroy

  default_scope :order=>'ends_at ASC, created_at ASC'
end
