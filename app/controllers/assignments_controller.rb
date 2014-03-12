class AssignmentsController < ApplicationController
  # include Humanize
  before_action :set_assignment, only: [:show, :show_all_answers, :edit, :update, :destroy, :stats, :grades, :export_grades, :resolve_action_item]
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
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.permit(:course_id)
      params.permit(:grade_id)
      params.permit(:assignment_grade => [:credit])
      params.require(:assignment).permit(:title, :description, :milestone_list, :due_at, :open_at, :rubric_items_attributes=>[
        :id, :title, :short_title, :open_at, :ends_at, :final_only,
        :min, :max, :min_label, :max_label, :_destroy, :answer_attributes_attributes=>[:id, :description, :score, :_destroy]], :taggings_attributes=>[:id, :open_at, :close_at, :review_open_at, :review_close_at]) #don't allow user id. set to current user
    end
end
