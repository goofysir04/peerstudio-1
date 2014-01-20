class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  # GET /reviews
  # GET /reviews.json
  def index
    @answer = Answer.find(params[:answer_id])
    @reviews = @answer.reviews
    @feedback_items_by_rubric_item = @answer.feedback_items.group_by(&:rubric_item_id)
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    @feedback_items_by_rubric_item = @review.feedback_items.group_by(&:rubric_item_id)
  end

  # GET /reviews/new
  def new
    @answer = Answer.find(params[:answer_id])
    @review = Review.new(answer: @answer, user: current_user, assignment: @answer.assignment)

    @answer.assignment.rubric_items.each do |item|
      @review.feedback_items.build(rubric_item: item)
    end

    # raise @review.feedback_items.count.inspect
  end

  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(review_params.merge(user: current_user, answer: Answer.find(params[:answer_id])))
    @review.assignment = @review.answer.assignment
    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: 'Review was successfully created.' }
        format.json { render action: 'show', status: :created, location: @review }
      else
        format.html { render action: 'new' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.permit(:answer_id)
      params.permit(:review_text)
      params.require(:review).permit(:answer_id,:out_of_box_answer,:feedback_items_attributes=>[:id, :rubric_item_id, :like_feedback, :wish_feedback, :score, :review_id, :answer_attribute_ids=>[]])
    end
end
