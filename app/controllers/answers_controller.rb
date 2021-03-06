class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :edit, :update, :destroy,:star,
    :submit_for_feedback, :submit_for_grades, :unsubmit_for_feedback, :unsubmit_for_grades,
    :feedback_preferences,
    :reflect, :clone]
  before_action :set_assignment, only: [:new]
  before_filter :authenticate_user!
  # GET /answers
  # GET /answers.json
  def index
    redirect_to root_path and return unless current_user.admin? #FIXME Make this it is visible to instructors
    @answers = Answer.where('assignment_id = ? and active =?', params[:assignment_id], true).order('user_id').order('created_at DESC').paginate(:page => params[:page])
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    respond_to do |format|
      format.html {redirect_to root_path}
      format.text {render text: @answer.response}
    end
  end

  # GET /answers/new
  def new

    current_user.tried_answering = true
    current_user.save!
    @latest_answer = Answer.where(assignment: @assignment, user: current_user, review_completed: false).order('created_at desc').first

    if !@latest_answer.nil?
      if !@latest_answer.submitted?
        redirect_to edit_answer_path(@latest_answer), notice: "We took you to the draft you were already editing" and return
      else
        redirect_to answer_reviews_path(@latest_answer), notice: "Here are the reviews on your last submitted submission. If you have enough feedback, click 'Stop Reviewing'." and return
      end
    end
    #else
    #if in waitlist, don't allow to create
    if current_user.get_and_store_experimental_condition!(@assignment.course) == "waitlist"
      redirect_to waitlist_assignment_path(@assignment) and return
    end

    @latest_answer_review_completed = Answer.where(assignment: @assignment, user: current_user, review_completed: true).order('updated_at desc').first
    if @latest_answer_review_completed.nil?
      @answer = Answer.new
      @answer.assignment = @assignment
      @answer.active = false
      @answer.user = current_user
      @answer.response = @assignment.template unless @assignment.template.blank?
    else
      redirect_to reflect_answer_path(@latest_answer_review_completed) and return
    end
    assignment = Assignment.find(params[:assignment_id])
    if assignment.course.students.exists?(current_user.id).nil?
      assignment.course.students << current_user
    end
    draft_type = params[:draft_type].nil? ? "Final Draft" : params.require(:draft_type)
    @answer.revision_list = draft_type
    if @answer.save
      redirect_to edit_answer_path(@answer)
    else
      redirect_to root_path, alert: "We couldn't create an answer now. Please try again, or report a bug."
    end
  end

  # GET /answers/1/edit
  def edit
    unless @answer.user == current_user or current_user.instructor_for?(@answer.assignment.course)
      redirect_to assignment_path(@answer.assignment), alert: "You can only edit your own answers!" and return
    end
    @trigger = TriggerAction.pending_action("review_required", current_user, @answer.assignment)
  end
  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)
    @answer.assignment = Assignment.find(params[:assignment_id])
    @answer.user = current_user

    respond_to do |format|
      if @answer.save
        format.html { redirect_to (@answer.assignment or @answer), notice: 'Answer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @answer }
        format.js
      else
        format.html { render action: 'new' }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    unless @answer.user == current_user or current_user.instructor_for?(@answer.assignment.course)
      redirect_to assignment_path(@answer.assignment), alert: "You can only edit your own answers!" and return
    end

    if @answer.submitted?
      redirect_to @answer.assignment, alert: "You submitted this answer for a review, so you can't change it anymore." and return
    end
    respond_to do |format|
      if @answer.update(answer_params.merge(active: true)) #set active to true so the answer shows up everywhere
        format.html { redirect_to (@answer), notice: 'Answer was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js {flash[:alert] = @answer.errors.full_messages.join(","); render}
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @assignment = @answer.assignment
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to @assignment }
      format.json { head :no_content }
    end
  end

  def submit_for_feedback
    @answer.submitted = true
    @answer.submitted_at = Time.now
    trigger = TriggerAction.add_trigger(current_user, @answer.assignment, trigger: "review_required", count: 2)
    respond_to do |format|
      if @answer.update(answer_params.merge(active: true)) and @answer.save and trigger.save
        format.html {redirect_to review_first_assignment_path(@answer.assignment)}
        format.json { head :no_content }
        format.js
      else
        format.html {redirect_to answer_path(@answer), alert: "We couldn't submit your assignment because " + @answer.errors.full_messages.join(". ")}
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def feedback_preferences
    render layout: "one_column"
  end

  def unsubmit_for_feedback
    # @answer.submitted = false
    @answer.is_final = false
    @answer.review_completed = true
    respond_to do |format|
      if @answer.save
        trigger = TriggerAction.add_trigger(current_user, @answer.assignment, trigger: "review_required", count: -2)
        trigger.save!
        format.html {redirect_to reflect_answer_path(@answer), notice: "We'll stop asking students to review your draft now."}
        format.json { head :no_content }
        format.js
      else
        format.html {redirect_to answer_path(@answer), alert: "We couldn't reverse your submission because" + @answer.errors.full_messages.join(". ")}
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def submit_for_grades
    @answer.submitted = true
    @answer.is_final = true
    @answer.submitted_at = Time.now
    trigger = TriggerAction.add_trigger(current_user, @answer.assignment, trigger: "review_required", count: 2)
    respond_to do |format|
      if @answer.save and trigger.save
        format.html {redirect_to assignment_path(@answer.assignment), notice: "Your draft was submitted to be graded"}
        format.json { head :no_content }
        format.js
      else
        format.html {redirect_to answer_path(@answer), alert: "We couldn't submit your assignment because " + @answer.errors.full_messages.join(". ")}
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def unsubmit_for_grades
    authenticate_user_is_instructor!(@answer.assignment.course)
    @answer.is_final = false
    respond_to do |format|
      if @answer.save
        format.html {redirect_to stats_assignment_path(@answer.assignment), notice: "Marked submission as non-final"}
        format.json { head :no_content }
        format.js
      else
        format.html {redirect_to stats_assignment_path(@answer.assignment), alert: "We couldn't undo that because " + @answer.errors.full_messages.join(". ")}
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  #To import csv answers

  def upgrade
    #from submitted for early feedback to submitted for final feedback
    @answer = Answer.find(params[:id])
    @answer.submitted = true
    @answer.is_final = true
    @answer.submitted_at = Time.now
    respond_to do |format|
      if @answer.save
        format.html {redirect_to assignment_path(@answer.assignment), notice: "Your draft was submitted to be graded"}
        format.json { head :no_content }
        format.js
      else
        format.html {redirect_to answer_path(@answer), alert: "We couldn't submit your assignment because " + @answer.errors.full_messages.join(". ")}
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def upload
    Answer.import(params[:file])
    redirect_to answers_path, :notice => "File imported"
  end

  def upload_attachment
    @answer = Answer.find(params[:id])
    @attachment = @answer.attached_assets.new(:asset => params[:file])

    if @attachment.save!
      respond_to do |format|
        format.html {redirect_to root_path}
        format.js {render layout: nil}
      end
    else
      redirect_to root_path
    end
  end

  def clone
    @cloned_answer = @answer.next_version
    if @cloned_answer.nil?
      @cloned_answer = Answer.new(user: current_user, assignment: @answer.assignment, previous_version: @answer,
        response: @answer.response, revision_list: @answer.revision_list,
        active: false, submitted: false)
      @cloned_answer.save!

      @answer.review_completed = true
      @answer.save!
    end

    respond_to do |format|
      if @answer.update(answer_params) #set active to true so the answer shows up everywhere
        format.html { redirect_to edit_answer_path(@cloned_answer) }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js {flash[:alert] = @answer.errors.full_messages.join(","); render}
      end
    end
  end

  def reflect

  end

  #toggles star
  def star
    @answer.starred = !@answer.starred
    if @answer.save
      respond_to do |format|
        format.html {redirect_to answer_reviews_path(@answer)}
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_answer
      @answer = Answer.find(params[:id])
    end

    def set_assignment
      @assignment = Assignment.find(params[:assignment_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def answer_params
      params.permit(:assignment_id)
      params.permit(:page)
      params.require(:answer).permit(:response, :revision_name, :revision_list, :question_id, :user_id, :predicted_score, :current_score, :evaluations_wanted, :total_evaluations, :confidence, :assignment_id,
        :reflection, :review_request, :revision_email_sent, :useful_feedback)
    end
end
