class Assessment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  belongs_to :question

  has_many :evaluations
end
