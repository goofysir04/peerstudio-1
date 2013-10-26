class Verification < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  belongs_to :answer_attribute
  belongs_to :question

  def self.get_next_verification(user, question)
  	#Find evaluations that need verification
  	Evaluation.where('question_id = ? and verified_true_count < 2 and verified_false_count < 2 and user_id <> ? and score is null', question.id,user.id).
  	order('(verified_true_count+verified_false_count) ASC').limit(8)
  end

  def self.save_verification(user, question_id, answer_id, answer_attribute_id, verifiedTrue, started_at)
  	#Two things need to happen. 
    #First, save the verification
    v = new(user_id: user.id, question_id: question_id, answer_id: answer_id, answer_attribute_id: answer_attribute_id, verified: verifiedTrue)
    v.started_at = started_at
    return false unless v.save
  	#Second, change the evaluation. If the evaluation has enough positive verifications, 
  	#move it to the completed pool. If enough negative verifications, move answer identification pool.
    e = Evaluation.where("answer_id = ? and answer_attribute_id = ?", answer_id, answer_attribute_id).first()
    return false if e.nil?

    if verifiedTrue
      e.increment!(:verified_true_count)
    else
      e.increment!(:verified_false_count)
    end
    return true
  end
end
