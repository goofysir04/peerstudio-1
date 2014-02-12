class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  # GET /reviews
  # GET /reviews.json
  def index
    @answer = Answer.find(params[:answer_id])
    @reviews = @answer.reviews
    @feedback_items_by_rubric_item = @answer.feedback_items.group_by(&:rubric_item_id)
    unless @reviews.empty?
      @reviews.each do |r|
        (@feedback_items_by_rubric_item["comments"] ||= []) << r.comments
      end
    end
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    @feedback_items_by_rubric_item = @review.feedback_items.group_by(&:rubric_item_id)
    unless @review.comments.empty?
      (@feedback_items_by_rubric_item["comments"] ||= []) << @review.comments
    end
  end

  # GET /reviews/new
  def new
    @answer = Answer.find(params[:answer_id])
    @review = create_review_for_answer(@answer)
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

  #Create a new review with a particular type 
  # such as paired, exchange, final etc
  def create_with_type
    @submitter = User.find_by_email(params[:typed_review][:email])
    review_type = params[:typed_review][:type]
    if @submitter.nil? and review_type != "final"
      redirect_to assignment_path(params[:assignment_id]), alert: "We didn't find a user with the address #{params[:typed_review][:email]}" and return
    end
    redirect_to assignment_path(params[:assignment_id]), alert: "You can't review yourself!" and return if @submitter==current_user 
    
    
    case review_type
    when "exchange"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(user_id: @submitter.id, assignment_id: params[:assignment_id])
    when "paired"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(assignment_id: params[:assignment_id]).where("user_id NOT in (?)", [@submitter.id, current_user.id])
    else
      redirect_to assignment_path(params[:assignment_id]), alert: "That review type has not opened yet." and return 
    end

    if @answers.empty?
      redirect_to assignment_path(params[:assignment_id]), alert: "We didn't find any drafts to review" and return 
    end

    @answer = @answers.order("RANDOM()").first
    @review = create_review_for_answer(@answer, params[:typed_review][:type])

    if review_type == "paired"
      @review.copilot_email = @submitter.email
    end 
    @review.save!
    redirect_to edit_review_path(@review)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.permit(:answer_id)
      params.permit(:assignment_id)
      params.permit(:typed_review).permit(:email,:type, :revision)

      params.require(:review).permit(:answer_id, :comments, :out_of_box_answer, :copilot_email, :feedback_items_attributes=>[:id, :rubric_item_id, :like_feedback, :wish_feedback, :score, :review_id, :answer_attribute_ids=>[]])
    end

    def create_review_for_answer(answer, type=nil)
          reviews = Review.where(answer: answer, user: current_user, assignment: answer.assignment, review_type: type)
          unless reviews.empty?
            return reviews.first
          end
          #else
          review = Review.new(answer: answer, user: current_user, assignment: answer.assignment, review_type: type)

          answer.assignment.rubric_items.each do |item|
            review.feedback_items.build(rubric_item: item)
          end

          review
    end
end
