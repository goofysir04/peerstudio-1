require 'csv'
require 'uri'
require 'net/https'
require 'format'

class AnswerGrade < ActiveRecord::Base
  table_name = "answer_grades"
end

class Answer < ActiveRecord::Base
  #To push grades
  API_KEY = "iqw9WQi3MgvmOJsK"
  has_many :attached_assets, :as => :attachable
  accepts_nested_attributes_for :attached_assets, :allow_destroy => true

  belongs_to :question
  belongs_to :user
  belongs_to :assignment

  belongs_to :previous_version, class_name: "Answer"

  has_many :reviews, :dependent => :destroy
  has_many :feedback_items, through: :reviews
  has_many :rubric_items, through: :feedback_preferences
  has_many :assessments

  acts_as_taggable_on :revisions

  validate :revisions_are_valid
  validate :only_one_final, on: :update

  scope :reviewable, -> {where(submitted:true, active: true)}
  
  def self.get_next_identify_for_user_and_question(user, question)

    if self.should_get_ground_truth_assignment(user, question)
      return self.get_ground_truth_assignment(user, question)
    else
      return self.where("answers.user_id <> ? AND answers.question_id = ? AND total_evaluations < evaluations_wanted AND confidence < 1 AND evaluation_type='default' AND answers.id NOT in (SELECT answer_id from assessments where assessments.user_id=?)", user.id, question, user.id)
      .order("(evaluations_wanted - total_evaluations) DESC").first()
    end
  end

  def active_reviews
    self.reviews.where(active: true)
  end

  def versions
    (Answer.where(assignment: self.assignment, user: self.user, active: true).order('created_at') << self)
  end
  
  def revision_name
    #really this should only be one tag, but comma separate if more
    self.revision_list
  end

  def revision_name=(val)
    raise NotImplementedError("setting directly is deprecated. Use the revisions tag helpers")
  end

  def is_latest_revision?
    Answer.where(assignment: self.assignment, user: self.user).where('created_at > ?', self.created_at).empty?
  end

  def latest_revision
    Answer.where(assignment: self.assignment, user: self.user).order('created_at DESC').first
  end

  def revisions_are_valid
    other_answers_tagged_like_this = Answer.where(assignment: self.assignment, user: self.user, active: true).where('answers.id <> ?', self.id).tagged_with(self.revision_list)
    #Sort of an arbitrary cutoff.
    if other_answers_tagged_like_this.count > 10
      errors.add :revision_list, "You already have more than ten drafts that are #{self.revision_list}. You can't create any more."
    end
  end

  def only_one_final
    other_final_answers = Answer.where(assignment: self.assignment, user: self.user, is_final: true).where.not(id: self.id)
    if other_final_answers.count > 0 and self.is_final?
      errors.add :is_final, "You can only submit one draft as your final for each assignment"
    end
  end
  
  def next_version
    if Answer.where(previous_version: self).exists?
      return Answer.where(previous_version: self).first
    else
      return nil
    end
  end
  
  def feedback_items_by_rubric_item
    grouped_items = self.feedback_items.select {|r| r if r.review.active and r.review.review_method=="normal"}.group_by(&:rubric_item_id)

    if self.user.get_and_store_experimental_condition!(self.assignment.course) == "batched_email"
      grouped_items = self.feedback_items.select {|r| r if r.review.active and r.review.review_method=="normal" and r.review.completed_at < 1.day.ago}.group_by(&:rubric_item_id)
    end
    reviews = self.reviews.where(active: true)
    if self.user.get_and_store_experimental_condition!(self.assignment.course) == "batched_email"
      reviews = self.reviews.where(active: true).where('completed_at < ?', 1.day.ago)
    end
    unless reviews.empty?
      reviews.each do |r|
        (grouped_items["comments"] ||= []) << r.comments
        (grouped_items["reviewers"] ||= []) << r.user
      end
    end
    return grouped_items
  end

  def self.should_get_ground_truth_assignment(user, question)
    #First return false if this user has already identified a ground truth assignment. 
    ground_truths_assessed_so_far = Assessment.where("question_id =? and user_id = ? and answer_type='ground_truth'", question, user).count
    return false if ground_truths_assessed_so_far > 0 
    #else, 
    answers_assessed_so_far = Assessment.where("question_id = ? and user_id = ?", question, user).count
    #choose yes based on random choice. 
    return answers_assessed_so_far/4.0 > rand
  end

  def self.get_ground_truth_assignment(user, question)
    return self.where("answers.user_id <> ? AND answers.question_id = ? and answers.evaluation_type='ground_truth'", user, question).order("total_evaluations ASC").first()
  end

  def self.get_next_evaluate_for_user_and_question(user, question)
    if self.should_get_ground_truth_assignment(user, question)
      return self.get_ground_truth_assignment(user, question)
    else
      return self.where("answers.user_id <> ? AND answers.question_id = ? AND total_evaluations < evaluations_wanted AND confidence < 1 AND evaluation_type='baseline' AND answers.id NOT in (SELECT answer_id from assessments where assessments.user_id=?)", user.id, question, user.id)
      .order("(evaluations_wanted - total_evaluations) DESC").first()
    end
  end

  def get_missing_attributes
    evaluations_with_attrs = Evaluation.where("answer_id=? and score is null", self.id)
    return AnswerAttribute.where("question_id=? and is_correct =? and id not in (?)", self.question_id, true, evaluations_with_attrs.map(&:answer_attribute_id))
  end

  def get_grade
    AnswerGrade.where("answer_id = ?", id)
  end

  def new_get_grade
    #use the existing grade if present
    if self.state == "graded"
      return self.current_score
    end

    grades = AnswerGrade.where("answer_id = ?", id)

    if grades.nil? or grades[0].nil?
      #try to find baseline grades
      num_baseline_evals = Evaluation.where("answer_id=? and score is not null", self.id).count
      if num_baseline_evals > 0
        return Evaluation.where("answer_id=? and score is not null", self.id).average('score').to_f
      else
        return nil
      end
    end
    grade = grades[0]

    case self.question.score_aggregation_method
      when "sum"
        final_grade = ([question.min_score,grade["final_score"].to_f,question.max_score].sort[1]).floor
      when "average"
        final_grade = ([question.min_score,grade["avg_final_score"].to_f,question.max_score].sort[1]).floor
      else #assume sum by default
        final_grade = ([question.min_score,grade["final_score"].to_f,question.max_score].sort[1]).floor
    end
    return final_grade
  end


  def self.reviewable_answers(assignment_id,user_id,revision_name)
    reviewed_already = Review.where(user_id: user_id, active: true)
    reviewed_answers = reviewed_already.map {|r| r.answer_id}
      # raise @reviewed_answers.inspect
    reviewed_answers << 0 if reviewed_answers.blank?
    answers = Answer.tagged_with(revision_name).where(active: true, submitted:true, assignment_id: assignment_id, is_blank_submission: false).where("user_id NOT in (?) and answers.id NOT in (?)", user_id, reviewed_answers)
    return answers.count
  end


  class ImportJob <  Struct.new(:file_text)
    def perform
      print "STARTing job"
      spreadsheet = CSV.parse(file_text, {:headers => :first_row})
      spreadsheet.each do |row|
        owning_user = User.find_by_email(row["email"])

        if owning_user.nil?
        #this is a dummy password
          owning_user = User.new :password => Devise.friendly_token[0,20], :email=> row["email"]
          owning_user.save
        end
        answer = Answer.where(:question_id => row["question_id"], :user_id => owning_user.id).first()
        if answer.nil? 
          answer = Answer.new
        end

        answer.update_attributes(:question_id  => row["question_id"],:response => row["response"].to_s.force_encoding("UTF-8"), :user_id => owning_user.id,
          :predicted_score => row["predicted_score"],
            :current_score => row["current_score"],
            :evaluations_wanted => row["evaluations_wanted"],
            :total_evaluations => row["total_evaluations"],
            :confidence => row["confidence"],
            :evaluation_type => row["evaluation_type"])
        answer.save!
        # print "Answer saved"
      end

      print "FINISHing job"
    end
  end

  def self.import(file)
    raise "Unknown file type" if File.extname(file.original_filename) != ".csv"
    Delayed::Job.enqueue ImportJob.new(file.read)
  end
end


