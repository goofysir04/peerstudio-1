class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :edit, :update, :destroy,:star, :autosubmit]
  before_action :set_assignment, only: [:new]
  before_filter :authenticate_user!
  # before_filter :authenticate_user_is_admin!
  # GET /answers
  # GET /answers.json
  def index
    redirect_to root_path and return unless current_user.admin? #FIXME Make this so students can only see it after the due date.
    @answers = Answer.where('assignment_id = ? and active =?', params[:assignment_id], true).order('user_id').order('created_at DESC')
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    redirect_to root_path
  end

  # GET /answers/new
  def new
    @answer = Answer.new
    @answer.assignment = @assignment
    @answer.active = false
    @answer.user = current_user
    if @answer.save 
      redirect_to edit_answer_path(@answer)
    else
      redirect_to root_path, alert: "We couldn't create an answer now. Please try again, or report a bug."
    end
  end

  # GET /answers/1/edit
  def edit
    unless @answer.user == current_user or current_user.admin?
      redirect_to assignment_path(@answer.assignment), alert: "You can only edit your own answers!" and return
    end
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
    unless @answer.user == current_user or current_user.admin?
      redirect_to assignment_path(@answer.assignment), alert: "You can only edit your own answers!" and return
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
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to answers_url }
      format.json { head :no_content }
    end
  end

  def autosubmit

    if params[:doIt] == "true"
      @answer.in_progress = false
    elsif params[:doIt] == "false"
      # raise @answer.inspect  
      @answer.in_progress = true
    end
    
    respond_to do |format|
      if @answer.save
        format.html {redirect_to assignment_path(@answer.assignment), notice: "Your draft has been submitted"}
        format.json { head :no_content }
        format.js
      else
        format.html {redirect_to answer_path(@answer), alert: "We couldn't submit your assignment because " + @answer.errors.full_messages.join(". ")}
        format.json { render json: @answer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  #To import csv answers
  def upload
    Answer.import(params[:file])
    redirect_to answers_path, :notice => "File imported"
  end

  def upload_attachment
    @answer = Answer.find(params[:id])
    @attachment = @answer.attached_assets.new(:asset => params[:file])

    if @attachment.save
      respond_to do |format|
        format.html {redirect_to root_path}
        format.js {render layout: nil}
      end
    else
      redirect_to root_path
    end
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
      params.permit(:doIt)
      params.require(:answer).permit(:response, :revision_name, :revision_list, :question_id, :user_id, :predicted_score, :current_score, :evaluations_wanted, :total_evaluations, :confidence, :assignment_id)
    end
end
