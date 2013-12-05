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

    @completed_assessments = current_user.assessments.where(question_id: @question.id).count
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

    @answer = Answer.find(params[:evaluation][:answer_id])

    @assessment.answer_type = @answer.evaluation_type
    
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
        evaluation = Evaluation.where("question_id = ? and answer_id= ? and answer_attribute_id=?", v.question_id, v.answer_id, v.answer_attribute_id).first()
        if v.verified? 
          evaluation.decrement!(:verified_true_count)
        else
          evaluation.decrement!(:verified_false_count)
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
    @answer = Answer.get_next_evaluate_for_user_and_question(current_user, @question) #TODO fix actual user
    
    #If we've exhausted all our baseline sample, go find evaluations for the rest of the pool.
    if @answer.nil?
      @answer = Answer.get_next_identify_for_user_and_question(current_user, @question)
    end

    if @answer.nil?
      flash[:notice] = "We have no more answers for you to evaluate"
      redirect_to root_path and return
    end
    @completed_assessments = current_user.assessments.where(question_id: @question.id).count

    #Create a new evaluation. This particular evaluation is never saved
    @evaluation = Evaluation.new(question_id:@question.id,answer_id:@answer.id)
    
  end

  def create_baseline_assessment
    if params[:evaluation][:score].blank?
      flash[:alert] = "Please enter a score."
      redirect_to grade_baseline_path(params[:evaluation][:question_id]) and return
    end

    @question = Question.find(params[:evaluation][:question_id])
    score = (params[:evaluation][:score]).to_f
    if score < @question.min_score or score > @question.max_score
      flash[:alert] = "Please enter a score between #{@question.min_score} and #{@question.max_score}"
      redirect_to grade_baseline_path(params[:evaluation][:question_id]) and return
    end

    @assessment = Assessment.find_or_initialize_by(user_id: current_user.id, question_id:params[:evaluation][:question_id],
      answer_id: params[:evaluation][:answer_id])
    @assessment.comments = params[:comments]
    @assessment.started_at = params[:start_assessment_time]

    @answer = Answer.find(params[:evaluation][:answer_id])
    @assessment.answer_type = @answer.evaluation_type

    if @assessment.persisted?
      flash[:alert] = "You've already submitted your assessment for that question"
      redirect_to grade_baseline_path(assessment_attributes[:question_id]) and return
    end

    @evaluation = Evaluation.new evaluation_attributes()
    @evaluation.user_id = current_user.id
    @evaluation.assessment = @assessment

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

  def my_grades
    @answer_one = Answer.where("question_id = 1 and user_id=?", current_user.id).first()
    if @answer_one.nil?
      @evaluations_one = nil
    else
      @evaluations_one = Evaluation.where("answer_id=? and score is null", @answer_one.id)

      @attributes_missing_one = AnswerAttribute.where("question_id=1 and is_correct =? and id not in (?)", true, @evaluations_one.map(&:answer_attribute_id))
      grades = @answer_one.get_grade[0]

      if grades.nil?
        @evaluations_one = nil
        baseline_evaluations_count = Evaluation.where("answer_id=? and score is not null", @answer_one.id).count
        if baseline_evaluations_count > 0
          answer_grade_one = Evaluation.where("answer_id=? and score is not null", @answer_one.id).average('score')
        end
      else
        answer_grade_one = ([0.0,grades["avg_final_score"].to_f,1.0].sort[1]).floor
      end

      if !answer_grade_one.nil? and @answer_one.state == "identify"
        @answer_one.current_score = answer_grade_one
        @answer_one.state="graded"
        @answer_one.save!
      end
    end

    @answer_two = Answer.where("question_id = 2 and user_id=?", current_user.id).first()
    if @answer_two.nil?
      @evaluations_two = nil
    else
      @evaluations_two = Evaluation.where("answer_id=? and score is null", @answer_two.id)
      @attributes_missing_two = AnswerAttribute.where("question_id=2 and is_correct =? and id not in (?)", true, @evaluations_two.map(&:answer_attribute_id))
      grades = @answer_two.get_grade[0]
      if grades.nil?
        @evaluations_two = nil
      else
        answer_grade_two = ([0.0,grades["final_score"].to_f,3.0].sort[1]).floor
      end

      if !answer_grade_two.nil? and @answer_two.state != "graded"
        @answer_two.current_score = answer_grade_two
        @answer_two.state="graded"
        @answer_two.save!
      end
    end
    @current_user_answers = Answer.where("user_id = ? ", current_user)
    @appeals = Appeal.where("answer_id IN (?)", @current_user_answers)
    # flash[:alert] = "Due to a technical problem, our grades script is being delayed for Question 2. Please check back after Nov 6 8am PDT"
  end

  def appeal
    @appeal = Appeal.new
    @appeal.answer= Answer.find(params[:id])
    @appeal.appeal_score = @appeal.answer.current_score
  end

  def create_appeal
    @appeal = Appeal.new(appeal_attributes)
    if @appeal.answer.user != current_user
      flash[:alert] ="You can only submit a regrade for your own answers"
      redirect_to root_path and return 
    else
      @appeal.experimental_condition =current_user.experimental_condition

      answer = @appeal.answer
      @appeal.question_id = answer.question_id
      answer.current_score = @appeal.appeal_score
      if @appeal.save and answer.save
        flash[:notice] ="Your request has been submitted, and your score is updated"
        redirect_to root_path and return 
      end
    end
  end

  def staff_grade
    @question = Question.find(params[:id])
    @answer = Answer.where("question_id = ? and current_score is NULL and id not in (select answer_id from evaluations where score is not null)", @question) #TODO fix actual user

    if @answer.nil?
      flash[:notice] = "We have no more answers for you to evaluate"
      redirect_to root_path and return
    end
    @completed_assessments = current_user.assessments.where(question_id: @question.id).count

    #Create a new evaluation. This particular evaluation is never saved
    raise @answer.inspect
    @evaluation = Evaluation.new(question_id:@question.id,answer_id:@answer.id)
    @action_path = create_staff_grade_path
    render 'baseline_evaluate'
  end

  def create_staff_grade
    if params[:evaluation][:score].blank?
      flash[:alert] = "Please enter a score."
      redirect_to staff_grade_path(params[:evaluation][:question_id]) and return
    end

    unless current_user.admin?
      flash[:alert] = "Nope, you can't do that" and redirect_to root_path and return
    end

    @question = Question.find(params[:evaluation][:question_id])
    score = (params[:evaluation][:score]).to_f
    if score < @question.min_score or score > @question.max_score
      flash[:alert] = "Please enter a score between #{@question.min_score} and #{@question.max_score}"
      redirect_to grade_baseline_path(params[:evaluation][:question_id]) and return
    end

    @assessment = Assessment.find_or_initialize_by(user_id: current_user.id, question_id:params[:evaluation][:question_id],
      answer_id: params[:evaluation][:answer_id])
    @assessment.comments = params[:comments]
    @assessment.started_at = params[:start_assessment_time]

    @answer = Answer.find(params[:evaluation][:answer_id])
    @assessment.answer_type = @answer.evaluation_type

    if @assessment.persisted?
      flash[:alert] = "You've already submitted your assessment for that question"
      redirect_to grade_baseline_path(assessment_attributes[:question_id]) and return
    end

    @evaluation = Evaluation.new evaluation_attributes()
    @evaluation.user_id = current_user.id
    @evaluation.assessment = @assessment

    @answer.increment!(:total_evaluations)

    @answer.staff_graded = true


    if @answer.save && @assessment.save && @evaluation.save
      flash[:notice] = "Thanks! Your evaluation was recorded"
      
      redirect_to staff_grade_path(params[:evaluation][:question_id]) and return
    else
      @assessment.destroy 
      flash[:alert] = "Errors! #{@evaluation.errors.full_messages.join(',')}"
      redirect_to staff_grade_path(params[:evaluation][:question_id]) and return
    end
  end


  private

  def evaluation_attributes
    params.require(:evaluation).permit(:answer_attribute, :question_id, :answer_id, :score)
  end

  def appeal_attributes
    params.require(:appeal).permit(:comments, :answer_id, :appeal_score)
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
