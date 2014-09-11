namespace :assignment do 
	task :send_emails_to_unrevised_answers => :environment do
		logger = Rails.logger
		
		logger.info "Sending emails to people who have gotten reviews, but have not revised their draft (within the past day)!"
		@assignments = Assignment.active
		@assignments.each do |a|
			unaltered_answers = Answer.where(assignment: a).where(["submitted = ? and updated_at < ? and revision_email_sent = ?", false, Time.now-1.day, false])
			unaltered_answers.each do |ans|
				received_reviews = Review.where(assignment: a, answer: ans).where("completed_at < ?", Time.now-1.day).count
				if received_reviews > 0
					ReviewMailer.delay.unrevised_answers_email(ans, a)
					ans.revision_email_sent = true
					ans.save!
				end
			end
		end
	end
end

