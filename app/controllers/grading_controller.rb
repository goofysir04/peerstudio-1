require 'time'

class GradingController < ApplicationController
	# before_action :assessment_attributes, only: [:create_assessment]
  before_filter :authenticate_user!

  def index
    @questions = Question.all
    @completed_identifications_by_question = Assessment.where("user_id = ?", current_user).group("question_id").count()
    @completed_verifications_by_question = Verification.where("user_id = ?", current_user).group(:question_id).count()

    @total_assessments = current_user.assessments.count
    @total_verifications = current_user.verifications.count
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
    
    @attributes = params[:evaluation][:answer_attribute]
    if @assessment.persisted?
      flash[:alert] = "You've already submitted your assessment for that question"
      redirect_to grade_identification_path(assessment_attributes[:question_id]) and return
    end
    @assessment.comments = params[:comments]
    @assessment.started_at = params[:start_assessment_time]
    assessment_attributes_saved = @assessment.save_answer_attributes(@attributes)

    #Now that we have an evaluation, increment the total number of evaluations
    @answer = Answer.find(@assessment.answer_id)
    @answer.increment!(:total_evaluations)
    if @assessment.save && assessment_attributes_saved
      flash[:notice] = "Thanks! Your evaluation was recorded (<a href='#{undo_grade_identification_path(@assessment.id)}'>Undo?</a>)"
      redirect_to next_identify_or_verify(@assessment.question_id) and return
    end
  end

  def undo_assessment
    @assessment = Assessment.find(params[:id])
    if @assessment.nil?
      flash[:alert] = "Couldn't find that evaluation."
      redirect_to root_path
    elsif @assessment.created_at < Time.now - 2.minute
      flash[:alert] = "Sorry, you can only undo an evaluation up to two minutes after it is created"
      redirect_to grade_identification_path(@assessment.question_id)
    else
      if @assessment.evaluations.count > 0
        @assessment.evaluations.destroy_all
      end

      verifications = Verification.where("user_id = ? and answer_id = ?", current_user, @assessment.answer_id)
      verifications.each do |v|
        if v.verified? 
          v.evaluation.decrement!(:verified_true_count)
        else
          v.evaluation.decrement!(:verified_false_count)
        end
      end
      verifications.destroy_all
      @assessment.answer.decrement!(:total_evaluations)

      if @assessment.destroy
        flash[:notice] = "Your assessment was undone"
        redirect_to grade_identification_path(@assessment.question_id)
      else
        flash[:alert] = "Sorry, your assessment could not be undone."
        redirect_to grade_identification_path(@assessment.question_id)
      end
    end  
  end

  def verify
  	#Which of these answers has this attribute?
    
    @question = Question.find(params[:id])
    @total_verification_count = current_user.verifications.count
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
    @start_time = params[:start_verification_time]
    if incoming_verifications.nil?
      redirect_to grade_verification_path(params[:question_id]), alert: "We didn't get any response. Did you forget to select if answers were marked correctly?"
    else
      incoming_verifications.each do |answer_id, attributes| 
        @answer = Answer.find(answer_id)
        attributes[:answer_attribute].each do |answer_attribute_id, verification|
          boolean_verification = verification == "correct"
          saved_verifications &&= Verification.save_verification(current_user,@answer.question_id, answer_id, answer_attribute_id, boolean_verification, @start_time)
        end
      end
      respond_to do |format|
        if saved_verifications
          format.html { redirect_to root_path, notice: 'You successfully verified assessments. You can verify more assessments below' }
        else
          format.html {redirect_to root_path, error: 'There was an error saving.'}
        end
      end
    end
  end

  def baseline_evaluate
    @question = Question.find(params[:id])
    @answer = Answer.get_next_identify_for_user_and_question(current_user, @question) #TODO fix actual user

    @completed_assessments = current_user.assessments.count

    #Create a new evaluation. This particular evaluation is never saved
    @evaluation = Evaluation.new(question_id:@question.id,answer_id:@answer.id)
    
  end

  def create_baseline_assessment
    if params[:evaluation][:score].blank?
      flash[:alert] = "Please enter a score."
      redirect_to grade_baseline_path(params[:evaluation][:question_id]) and return
    end
    @assessment = Assessment.find_or_initialize_by(user_id: current_user.id, question_id:params[:evaluation][:question_id],
      answer_id: params[:evaluation][:answer_id])
    @assessment.comments = params[:comments]
    @assessment.started_at = params[:start_assessment_time]

    @evaluation = Evaluation.new evaluation_attributes()
    @evaluation.user_id = current_user.id
    @evaluation.assessment = @assessment
    if @assessment.persisted?
      flash[:alert] = "You've already submitted your assessment for that question"
      redirect_to grade_baseline_path(assessment_attributes[:question_id]) and return
    end

    @answer = Answer.find(@assessment.answer_id)
    @answer.increment!(:total_evaluations)
    if @assessment.save && @evaluation.save
      flash[:notice] = "Thanks! Your evaluation was recorded"
      
      redirect_to next_identify_or_verify(params[:evaluation][:question_id]) and return
    else
      @assessment.destroy 
      flash[:alert] = "Errors! #{@evaluation.errors.full_messages.join(',')}"
      redirect_to next_identify_or_verify(params[:evaluation][:question_id]) and return
    end
  end

  private

  def evaluation_attributes
    params.require(:evaluation).permit(:answer_attribute, :question_id, :answer_id, :score)
  end

  def assessment_attributes
    params.permit(:question_id, :answer_id, :comments)
    params.permit(:verification)
  	params.permit(:evaluation => [{:answer_attribute => []}, :question_id, :answer_id])
  end

  def next_identify_or_verify(current_question_id)
    #If the current user has gone through all the identify problems, go do the verify ones instead.
    assessments_completed = current_user.assessments.where("question_id = ?", current_question_id).count
    verifications_completed = current_user.verifications.where("question_id = ?", current_question_id).count

    if current_user.experimental_condition == "baseline"
      if assessments_completed == 4
        flash[:notice] = "Thank you for your evaluations. You can evaluate more if you like."
        return root_path 
      else
        return grade_baseline_path(current_question_id)
      end
    elsif current_user.experimental_condition == "identify"
      if assessments_completed == 4
        flash[:notice] = "Thank you for your evaluations. You can evaluate more if you like."
        return root_path
      else
        return grade_identification_path(current_question_id)
      end
    else
      if assessments_completed >= 4 and verifications_completed < 8 #only show verifications path if not enough completed
        return grade_verification_path(current_question_id)
      else
        return grade_identification_path(current_question_id)
      end
    end
  end
end
