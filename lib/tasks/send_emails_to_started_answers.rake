namespace :assignment do 
	task :send_emails_to_started_answers => :environment do
		logger = Rails.logger
		
		logger.info "Sending emails to people who have started their answer but have not submitted it!"
		@assignments = Assignment.active
		@assignments.each do |a|
			unsubmitted_answers = Answer.where(assignment: a).where(["submitted = ? and updated_at < ? and updated_at > ?", false, Time.now-1.day, Time.now-3.days])
			unsubmitted_answers.each do |answer|
				ReviewMailer.delay.unsubmitted_answers_email(answer, a)
			end
		end
	end
end

