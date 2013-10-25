class Evaluation < ActiveRecord::Base
  belongs_to :question
  belongs_to :answer
  belongs_to :answer_attribute

  belongs_to :user

  belongs_to :assessment

  validates :score, :numericality => {:greater_than_or_equal_to => 0},
  	:allow_nil => true
end
