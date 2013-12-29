class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :edit, :update, :destroy]
  before_action :set_assignment, only: [:show, :edit, :update, :new, :index]
  before_filter :authenticate_user!
  # before_filter :authenticate_user_is_admin!
  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.all
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
  end

  # GET /answers/new
  def new
    @answer = Answer.new
  end

  # GET /answers/1/edit
  def edit
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)

    respond_to do |format|
      if @answer.save
        format.html { redirect_to @answer, notice: 'Answer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @answer }
      else
        format.html { render action: 'new' }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to @answer, notice: 'Answer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
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
        format.js
      end
    else
      redirect_to root_path
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
      params.require(:answer).permit(:response, :question_id, :user_id, :predicted_score, :current_score, :evaluations_wanted, :total_evaluations, :confidence)
    end
end
