class GradingController < ApplicationController
	before_action :assessment_attributes, only: [:create_assessment]
  before_filter :authenticate_user!

  def index
    @questions = Question.all
    @completed_identifications_by_question = Assessment.where("user_id = ?", current_user).group("question_id").count()
    @completed_verifications_by_question = Verification.where("user_id = ?", current_user).group(:question_id).count()
  end

  def identify
  	#Does it have any of these attributes?

  	#Find the question and an appropriate answer for grading
  	@question = Question.find(params[:id])
  	@answer = Answer.get_next_identify_for_user_and_question(current_user, @question) #TODO fix actual user

    @completed_assessments = current_user.assessments.count
  	#Find question attributes
  	@correct_attributes = @question.answer_attributes.where(:is_correct => true)
  	@incorrect_attributes = @question.answer_attributes.where(:is_correct => false)

  	#Create a new evaluation. This particular evaluation is never saved
    @evaluation = Evaluation.new(question_id:@question.id,answer_id:@answer.id)
  end

  def create_assessment
  	#First find if this assessment was already submitted
  	@assessment = Assessment.find_or_initialize_by(user_id: current_user.id, question_id:params[:evaluation][:question_id],
      answer_id: params[:evaluation][:answer_id])
    @assessment.comments = params[:comments]
    @attributes = params[:evaluation][:answer_attribute]
    if @assessment.persisted?
      flash[:alert] = "You've already submitted your assessment for that question"
      redirect_to grade_identification_path(assessment_attributes[:question_id]) and return
    end

    assessment_attributes_saved = @assessment.save_answer_attributes(@attributes)

    #Now that we have an evaluation, increment the total number of evaluations
    @answer = Answer.find(@assessment.answer_id)
    @answer.increment!(:total_evaluations)
    if @assessment.save && assessment_attributes_saved
      flash[:notice] = "Thanks! Your evaluation was recorded"
      redirect_to next_identify_or_verify @assessment.question_id
    end
  end

  def verify
  	#Which of these answers has this attribute?
    @total_verification_count = current_user.verifications.count
    @question = Question.find(params[:id])
    @evaluations = Verification.get_next_verification current_user, @question
    if @evaluations.empty? 
      respond_to do |format|
        format.html { redirect_to root_path, alert: "We have no assessments to verify (because your classmates haven't started grading yet!) Please check back in a couple hours."}
      end
    else
      @answer = @evaluations.first().answer
      @verification = Verification.new
    end
  end

  def create_verification
    saved_verifications = true
    incoming_verifications = params[:verification]
    if incoming_verifications.nil?
      redirect_to grade_verification_path(params[:question_id]), alert: "We didn't get any response. Did you forget to select if answers were marked correctly?"
    else
      incoming_verifications.each do |answer_id, attributes| 
        @answer = Answer.find(answer_id)
        attributes[:answer_attribute].each do |answer_attribute_id, verification|
          boolean_verification = verification == "correct"
          saved_verifications &&= Verification.save_verification(current_user,@answer.question_id, answer_id, answer_attribute_id, boolean_verification)
        end
      end
      respond_to do |format|
        if saved_verifications
          format.html { redirect_to root_path, notice: 'You successfully verified assessments.' }
        else
          format.html {redirect_to root_path, error: 'There was an error saving.'}
        end
      end
    end
  end

  private

  def assessment_attributes
    params.permit(:question_id, :answer_id, :comments)
    params.permit(:verification)
  	params.require(:evaluation).permit(:answer_attribute, :question_id, :answer_id)
  end

  def next_identify_or_verify(current_question_id)
    #If the current user has gone through all the identify problems, go do the verify ones instead.
    assessments_completed = current_user.assessments.where("question_id = ?", current_question_id).count
    if assessments_completed >= 4
      return grade_verification_path(current_question_id)
    elsif assessments_completed < 4
      return grade_identification_path(current_question_id)
    end
  end
end
