require 'CSV'

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  has_many :assessments
  
  def self.import(file)
  	spreadsheet = self.open_spreadsheet(file)
  	spreadsheet.each do |row|
  		answer = Answer.where(:question_id => row["question"], :user_id => row["user_id"]).first()
  		if answer.nil? 
  	 		answer = new
  	 	end

  	 	answer.update_attributes(:question_id  => row["question"],:response => row["response"], :user_id => row["user_id"],
				:predicted_score => row["predicted_score"],
			    :current_score => row["current_score"],
			    :evaluations_wanted => row["evaluations_wanted"],
			    :total_evaluations => row["total_evaluations"],
			    :confidence => row["confidence"])
		answer.save!
  	end
  end

  def self.open_spreadsheet(file)
	raise "Unknown file type" if File.extname(file.original_filename) != ".csv"
	return CSV.open(file.path, {:headers => :first_row})
  end


  def self.get_next_identify_for_user_and_question(user, question)
    return self.where("answers.user_id <> ? AND answers.question_id = ? AND total_evaluations < evaluations_wanted AND confidence < 1 AND answers.id NOT in (SELECT answer_id from `assessments` where assessments.user_id=?)", user.id, question, user.id)
    .order("(evaluations_wanted - total_evaluations) DESC").first()
  end
end
