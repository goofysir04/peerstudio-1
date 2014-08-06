class AssignmentsController < ApplicationController
  # include Humanize
  assignment_actions = [:show, :show_all_answers, :edit, :update, :destroy, :stats, :grades, :export_grades, :resolve_action_item, :review_first]

  before_action :set_assignment, only: assignment_actions
  # add_breadcrumb :set_breadcrumb_link, only: assignment_actions
  before_action :set_course, only: [:index, :new, :create]
  before_filter :authenticate_user!, except: :show
  before_filter :authenticate_user_is_admin!, only: [:stats, :update_grade, :export_grades]
  # GET /assignments
  # GET /assignments.json
  def index
    redirect_to course_path @course #Easiest to put things in one place
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    if user_signed_in?
      @trigger = TriggerAction.pending_action("review_required", current_user, @assignment)
      @my_answers = Answer.where(user: current_user, assignment: @assignment, active: true)
      @my_reviews = Review.where(answer_id: @my_answers, active: true, assignment_id: @assignment.id)
      @reviews_by_me = Review.where(active: true, assignment_id: @assignment.id).where("user_id = ? or copilot_email = ?", current_user.id,current_user.email)
      @out_of_box_answers_with_count = Review.where(assignment_id: @assignment.id, out_of_box_answer: true).group(:answer_id).count
      
      unless @out_of_box_answers_with_count.blank?
        @out_of_box_answers = @out_of_box_answers_with_count.reject {|k,v| v < 2 }
      end
      if @out_of_box_answers.blank?
        @out_of_box_answers = {}
      end
    end
    @all_answers = @assignment.answers.reviewable.limit(10)
    @starred_answers = @assignment.answers.reviewable.where(starred: true)
    render layout: "one_column"
  end

  def show_all_answers
    @all_answers = @assignment.answers.reviewable
    respond_to do |format| 
      format.js
    end
  end

  # GET /assignments/new
  def new
    #Course id is set in callback
    @assignment = Assignment.new(:course=>@course)
  end

  # GET /assignments/1/edit
  def edit
    #noop
  end

  # POST /assignments
  # POST /assignments.json
  def create
    # raise params.inspect
    @assignment = Assignment.new(assignment_params)
    @assignment.course = Course.find(params[:course_id])
    @assignment.user=current_user
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @assignment }
      else
        format.html { render action: 'new' }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    # raise assignment_params.inspect
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @course = @assignment.course
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to course_assignments_url(@course) }
      format.json { head :no_content }
    end
  end

  def stats
    @students = @assignment.course.students
    @milestones = @assignment.milestones

    @action_items = ActionItem.where(assignment: @assignment)

    @reviews_last_day_lagging = Review.where(assignment: @assignment).where("completed_at > ?", Time.now-1.day).count
    @submissions_last_day_lagging = @assignment.answers.where("submitted_at > ?", Time.now-1.day).count
    @revisions_last_day_lagging = @assignment.answers.where("created_at > ? and previous_version_id is NOT NULL", Time.now-1.day).count

    @top_reviewers_lagged = Review.where(assignment: @assignment).where('completed_at > ?', Time.now-1.day).group(:user_id).count.sort_by {|k,v| -v }[0..4].map {|u,v| [User.find(u),v]}
    @top_reviewers = Review.where(assignment: @assignment).group(:user_id).count.sort_by {|k,v| -v }[0..4].map {|u,v| [User.find(u),v]}
    @unreviewed_right_now = @assignment.answers.where(submitted: true, total_evaluations: 0, review_completed:false).count

    @submissions_total_submitted = @assignment.answers(submitted: true).count
  end

  def grades
    if current_user.admin? 
      @permitted_user = params[:user].nil? ? current_user : User.find(params.require(:user))
    else
      redirect_to @assignment and return unless @assignment.grades_released?
      @permitted_user = current_user
    end
    @grades = AssignmentGrade.where(assignment: @assignment, user: @permitted_user)
  end

  def update_grade
    @grade = AssignmentGrade.find(params[:grade_id])
    if(@grade.update(params.require(:assignment_grade).permit(:credit,:grade_type)))
      redirect_to grades_assignment_path(@grade.assignment, user: @grade.user), notice: "Grade updated"
    else
      redirect_to grades_assignment_path(@grade.assignment, user: @grade.user), alert: "Could not update grade"
    end
  end

  def export_grades
    respond_to do |format|
      format.csv { send_data AssignmentGrade.where(assignment_id: @assignment.id).export_to_csv, :filename => "gradebook.csv"}
    end
  end

  def resolve_action_item
    @action_item = ActionItem.find(params.permit(:item)[:item])

    @action_item.resolved = !@action_item.resolved?

    if @action_item.save
      respond_to do |format|
        format.html { redirect_to stats_assignment_path(@assignment) }
        format.js
      end
    end
  end

def review_first
    @trigger = TriggerAction.pending_action("review_required", current_user, @assignment)

    unless params[:recent_review].nil?
      @recent_review = Review.find(params[:recent_review])  
    end


    if @trigger.nil? 
      #this means that either the required reviews were completed, or that we never had a trigger. 
      #In either case, check if there are
      redirect_to root_path
    else
    #otherwise render
      render layout: "one_column"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_breadcrumb_link
      @navbar_links ||= []
      @navbar_links << "<a href='#{assignment_path}'>Assignment</a>"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.permit(:course_id)
      params.permit(:grade_id)
      params.permit(:assignment_grade => [:credit])
      params.permit(:recent_review)
      params.require(:assignment).permit(:title, :description, :template, :example, :milestone_list, :due_at, :open_at, :rubric_items_attributes=>[
        :id, :title, :short_title, :show_for_feedback, :show_for_final,
        :_destroy, :answer_attributes_attributes=>[:id, :description, :score, :attribute_type, :example, :_destroy]], :taggings_attributes=>[:id, :open_at, :close_at, :review_open_at, :review_close_at]) #don't allow user id. set to current user
    end

end
