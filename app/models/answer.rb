require 'csv'

class AnswerGrade < ActiveRecord::Base
  table_name = "answer_grades"
end

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  has_many :assessments
  
  def self.get_next_identify_for_user_and_question(user, question)
    return self.where("answers.user_id <> ? AND answers.question_id = ? AND total_evaluations < evaluations_wanted AND confidence < 1 AND evaluation_type='default' AND answers.id NOT in (SELECT answer_id from assessments where assessments.user_id=?)", user.id, question, user.id)
    .order("(evaluations_wanted - total_evaluations) DESC").first()
  end

  def self.get_next_evaluate_for_user_and_question(user, question)
    return self.where("answers.user_id <> ? AND answers.question_id = ? AND total_evaluations < evaluations_wanted AND confidence < 1 AND evaluation_type='baseline' AND answers.id NOT in (SELECT answer_id from assessments where assessments.user_id=?)", user.id, question, user.id)
    .order("(evaluations_wanted - total_evaluations) DESC").first()
  end

  def get_grade
    AnswerGrade.where("answer_id = ?", id)
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
            :confidence => row["confidence"])
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


