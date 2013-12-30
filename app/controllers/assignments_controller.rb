class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_course, only: [:index, :new, :create]
  before_filter :authenticate_user!
  # GET /assignments
  # GET /assignments.json
  def index
    redirect_to course_path @course #Easiest to put things in one place
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    @my_answers = Answer.where(user: current_user, assignment: @assignment)
  end

  # GET /assignments/new
  def new
    #Course id is set in callback
    @assignment = Assignment.new(:course=>@course)
  end

  # GET /assignments/1/edit
  def edit
    2.times do @assignment.rubric_items.build() end
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
    # raise params.inspect
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
      params.require(:assignment).permit(:title, :description, :due_at, :open_at,:rubric_items_attributes=>[
        :id,:title,:short_title,:ends_at, :final_only,
        :min, :max, :min_label, :max_label,:_destroy]) #don't allow user id. set to current user
    end
end
