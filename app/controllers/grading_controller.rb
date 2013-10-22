class GradingController < ApplicationController
	before_action :assessment_attributes, only: [:create_assessment]
  before_filter :authenticate_user!
  def identify
  	#Does it have any of these attributes?

  	#Find the question and an appropriate answer for grading
  	@question = Question.find(params[:id])
  	@answer = Answer.get_next_identify_for_user_and_question(1, @question) #TODO fix actual user

  	#Find question attributes
  	@correct_attributes = @question.answer_attributes.where(:is_correct => true)
  	@incorrect_attributes = @question.answer_attributes.where(:is_correct => false)

  	#Create a new evaluation. This particular evaluation is never saved
    @evaluation = Evaluation.new(question_id:@question.id,answer_id:@answer.id)
  end

  def create_assessment
  	#Create multiple evaluation objects
  	@assessment = Assessment.new(user_id: current_user, question_id:params[:evaluation][:question_id],
      answer_id: params[:evaluation][:answer_id])
    @attributes = params[:evaluation][:attribute]

    evaluations_saved = true
    #create a new evaluation for each checked attribute
    @attributes.each do |a| 
      evaluation = Evaluation.new params[:evaluation].slice(:question_id, :answer_id)
      evaluation.attribute = a
      evaluation.user = current_user
      evaluation.assessment = @assessment
      evaluations_saved &&= evaluation.save
    end

    raise "Does this work?"
  end

  def verify
  	#Which of these answers has this attribute?
  end

  private

  def assessment_attributes
    params.permit(:question_id, :answer_id)
  	params.require(:evaluation).permit(:answer_attribute, :question_id, :answer_id)
  end
end
