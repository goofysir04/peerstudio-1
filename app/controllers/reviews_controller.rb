class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy, :rate, :create_rating, :report_blank]
  before_action :set_answer, only: :review_answer
  before_filter :authenticate_user_is_admin!, only: :review_answer
  before_filter :authenticate_user!
  # GET /reviews
  # GET /reviews.json
  def index
    @answer = Answer.find(params[:answer_id])
    @trigger = TriggerAction.pending_action("review_required", current_user, @answer.assignment)

    if @trigger.nil? and @answer.reviews_first_seen_at.nil?
      @answer.reviews_first_seen_at = Time.now
      @answer.save!
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
    @answer = @review.answer

    @latest_reviewer_answer = Answer.where(assignment: @answer.assignment, user: current_user).order('updated_at desc').first
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
    # raise params.inspect
    respond_to do |format|
      @answer= @review.answer
      process_review_triggers_and_answer!(@review)
      if save_review_and_attributes!(@review)
        format.html { redirect_to review_first_assignment_path(@review.assignment, recent_review: @review), notice: 'Thanks, we sent that review to your classmate!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def report_blank
    # raise params.inspect
    respond_to do |format|
      @answer= @review.answer
      @answer.is_blank_submission = true
      @answer.save!
      process_review_triggers_and_answer!(@review)
      if (@review.update(active: true))
        format.html { redirect_to review_first_assignment_path(@review.assignment, recent_review: @review), notice: 'Thanks, we\'ll stop asking others to review that submission!' }
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
    @assignment = @review.assignment
    @review.destroy
    respond_to do |format|
      format.html { redirect_to @assignment }
      format.json { head :no_content }
    end
  end
  #Create a new review with a particular type 
  # such as paired, exchange, final etc
  def create_with_type

    current_user.tried_reviewing = true
    current_user.save!

    if current_user.experimental_condition == "waitlist"
      redirect_to waitlist_assignment_path(params[:id]) and return
    end

    @submitter = User.find_by_email(params[:typed_review][:email])
    review_type = params[:typed_review][:type]
    if @submitter.nil? and review_type != "final"
      redirect_to assignment_path(params[:id]), alert: "We didn't find a user with the address #{params[:typed_review][:email]}" and return
    end
    redirect_to assignment_path(params[:id]), alert: "You can't review yourself!" and return if @submitter==current_user 
    
    @reviewed_already = Review.where(user: current_user, active: true)
    @reviewed_answers = @reviewed_already.map {|r| r.answer_id}
      # raise @reviewed_answers.inspect
    @reviewed_answers << 0 if @reviewed_answers.blank?
    case review_type
    when "exchange"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(active: true, submitted:true, user_id: @submitter.id, assignment_id: params[:id])
    when "paired"
      @answers = Answer.tagged_with(params[:typed_review][:revision]).where(active: true,  submitted:true, assignment_id: params[:id]).where("user_id NOT in (?) and answers.id NOT in (?)", [@submitter.id, current_user.id], @reviewed_answers)
    when "final"
      @answers = Answer.where(active: true, submitted:true, review_completed:false, assignment_id: params[:id], is_blank_submission: false).where("user_id NOT in (?) and answers.id NOT in (?)", current_user.id, @reviewed_answers)
    else
      redirect_to assignment_path(params[:id]), alert: "That review type has not opened yet." and return 
    end

    if @answers.empty?
      redirect_to assignment_path(params[:id]), alert: "We didn't find any drafts to review" and return 
    end

    @answer = @answers.order("(pending_reviews + total_evaluations) ASC, submitted_at desc").first
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

    render layout: "one_column"
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

  def review_answer
    @review = create_review_for_answer(@answer, "final")
    if @review.save
      redirect_to edit_review_path @review
    else
      redirect_to @answer.assignment, alert: @review.errors.full_messages.join(",")
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
        :completion_metadata,
        :copilot_email, 
        :answer_attribute_weights => [:weight],
        :feedback_items_attributes=>[:id, :rubric_item_id, :like_feedback, :wish_feedback, :miscommunication, :score, :review_id, 
          :answer_attribute_ids=>[]])
    end

    def set_answer
      @answer = Answer.find(params[:answer_id])
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

    def process_review_triggers_and_answer!(review)
      answer = review.answer
      if !review.active?
        #The review is not active, so this is an update of a pending review
        answer.increment!(:total_evaluations)
        answer.decrement!(:pending_reviews) unless answer.pending_reviews == 0
        trigger = TriggerAction.add_trigger(current_user, @answer.assignment, count: -1, trigger:"review_required")
        if trigger.count == 0
          email_trigger = TriggerAction.where(["trigger = ?, user = ?, assignment = ?","email_count", current_user, @answer.assignment])
          if email_trigger.nil?
            email_trigger_save = TriggerAction.add_trigger(current_user, @answer.assignment, count: 4, trigger: "email_count")
            email_trigger_save.save!
          end
        end
        trigger.save!
      end
    end

    def save_review_and_attributes!(review)
      last_completed_at = review.completed_at
      if review.update(review_params.except(:answer_attribute_weights).merge(active: true, completed_at: Time.now))
        if last_completed_at.nil? or last_completed_at < 5.minutes.ago
          ReviewMailer.delay.reviewed_email(review.answer)
        end
        #add "last emailed" column
        review.set_answer_attribute_weights!(review_params[:answer_attribute_weights])
        return true
      else
        return false
      end
    end
end
