require 'csv'

class AnswerGrade < ActiveRecord::Base
  table_name = "answer_grades"
end

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  has_many :assessments
  
  def self.get_next_identify_for_user_and_question(user, question)

    if self.should_get_ground_truth_assignment(user, question)
      return self.get_ground_truth_assignment(user, question)
    else
      return self.where("answers.user_id <> ? AND answers.question_id = ? AND total_evaluations < evaluations_wanted AND confidence < 1 AND evaluation_type='default' AND answers.id NOT in (SELECT answer_id from assessments where assessments.user_id=?)", user.id, question, user.id)
      .order("(evaluations_wanted - total_evaluations) DESC").first()
    end
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


