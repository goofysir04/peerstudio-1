class Question < ActiveRecord::Base
	has_many :answer_attributes
	has_many :answers
end
