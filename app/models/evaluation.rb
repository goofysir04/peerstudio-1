class Evaluation < ActiveRecord::Base
  belongs_to :question
  belongs_to :answer
  belongs_to :answer_attribute

  belongs_to :user

  belongs_to :assessment
end
