class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy, :rate, :create_rating]
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
    unless @review.comments.blank?
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
    @answer = @review.answer
    @answer.increment!(:total_evaluations)
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
      if !@review.active?
        #The review is not active, so this is an update of a pending review
        @answer = @review.answer
        @answer.increment!(:total_evaluations)
        @answer.decrement!(:pending_reviews) unless @answer.pending_reviews == 0
      end
      if @review.update(review_params.merge(active: true, completed_at: Time.now))
        if @review.review_type=="final"
          format.html { redirect_to @review, notice: 'Review was successfully updated. Go to the assignment page to start a new review.' }
          format.json { head :no_content }
        else  
          format.html { redirect_to @review, notice: 'Review was successfully updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @assignment = @review.assignment
    @review.destroy
    respond_to do |format|
      format.html { redirect_to @assignment }
      format.json { head :no_content }
    end
  end

  def you_first
    @assignment = Assignment.find(3)
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
    
    @reviewed_already = Review.where(user: current_user, active: true)
    @reviewed_answers = @reviewed_already.map {|r| r.answer_id}
      # raise @reviewed_answers.inspect
    @reviewed_answers << 0 if @reviewed_answers.blank?
    case review_type
    when "exchange"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(active: true, user_id: @submitter.id, assignment_id: params[:assignment_id])
    when "paired"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(active: true, assignment_id: params[:assignment_id]).where("user_id NOT in (?) and answers.id NOT in (?)", [@submitter.id, current_user.id], @reviewed_answers)
    when "final"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(active: true, assignment_id: params[:assignment_id]).where("user_id NOT in (?) and answers.id NOT in (?)", current_user.id, @reviewed_answers)
    else
      redirect_to assignment_path(params[:assignment_id]), alert: "That review type has not opened yet." and return 
    end

    if @answers.empty?
      redirect_to assignment_path(params[:assignment_id]), alert: "We didn't find any drafts to review" and return 
    end

    @answer = @answers.order("(pending_reviews + total_evaluations) ASC").first
    @review = create_review_for_answer(@answer, params[:typed_review][:type])

    if review_type == "paired"
      @review.copilot_email = @submitter.email
    end 
    @review.save!
    redirect_to edit_review_path(@review)
  end

  def rate
    @feedback_items_by_rubric_item = @review.feedback_items.group_by(&:rubric_item_id)
    unless @review.comments.blank?
      (@feedback_items_by_rubric_item["comments"] ||= []) << @review.comments
    end
  end

  def create_rating
    respond_to do |format|
      if @review.update(review_params.merge(rating_completed: true))
        @my_answers = Answer.where({active: true, assignment_id: @review.answer.assignment_id, user: current_user})
        @next_review = Review.where({active: true, rating_completed: false, answer_id: @my_answers}).first
        if @next_review.blank?
          format.html { redirect_to assignment_path(@review.answer.assignment_id), notice: "Thank you for rating all your reviews" }
          format.json { head :no_content }
        else
          format.html {redirect_to rate_review_path(@next_review), notice: "Thank you for your rating!"}
          format.json { head :no_content }
        end
      else
        format.html { redirect_to action: 'rate', alert: "We couldn't save the rating. Please report a bug" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
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
      params.permit(:assignment_id)
      params.permit(:typed_review).permit(:email,:type, :revision)

      params.require(:review).permit(:answer_id, :comments, :out_of_box_answer, 
        :accurate_rating,
        :concrete_rating,
        :recognize_rating,
        :other_rating_comments,
        :reflection,
        :copilot_email, :feedback_items_attributes=>[:id, :rubric_item_id, :like_feedback, :wish_feedback, :score, :review_id, :answer_attribute_ids=>[]])
    end

    def create_review_for_answer(answer, type=nil)
      reviews = Review.where(answer: answer, user: current_user, assignment: answer.assignment, review_type: type, active:true)
      # if !reviews.empty? and type != "final"
      #   return reviews.first
      # end
      #else
      pending_reviews = Review.where(user: current_user, active: false)
      pending_reviews.each do |r|
        if(r.answer.assignment_id == answer.assignment_id and r.review_type==type)
          #return the first pending review from this student
          return r
        end
      end
      #else

      review = Review.new(answer: answer, user: current_user, assignment: answer.assignment, review_type: type)
      #Set to false to be sure you actually do the review before it's considered active
      review.active = false 
      answer.assignment.rubric_items.each do |item|
        review.feedback_items.build(rubric_item: item)
      end
      review.answer.increment!(:pending_reviews)
      review
    end
end
