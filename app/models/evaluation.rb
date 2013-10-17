class Evaluation < ActiveRecord::Base
  belongs_to :question
  belongs_to :answer
  belongs_to :attribute

  belongs_to :user
end
