class Assessment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  belongs_to :question

  has_many :evaluations

  def save_answer_attributes(answer_attributes)
  	answer_attributes.each do |a|
  		next if a.blank?
  		evaluation_exists = Evaluation.where("question_id = ? and answer_id= ? and answer_attribute_id=?", question_id, answer_id, a).exists?
  		unless evaluation_exists.nil?
  			#If this evaluation already exists, this is as good as creating a positive verification, 
  			#so let's do that instead of creating a new evaluation object

  			return Verification.save_verification(user, question_id, answer_id, a, true, nil)
  			
		else
			evaluation = Evaluation.new(question_id: question_id, answer_id: answer_id)
      		evaluation.answer_attribute_id = a
      		evaluation.user = user
      		evaluation.assessment = self

      		evaluation.save
      	end
  	end
  end
end
