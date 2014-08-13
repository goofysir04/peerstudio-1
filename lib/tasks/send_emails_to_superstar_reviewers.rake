namespace :assignment do 
	task :send_emails_to_superstar_reviewers => :environment do
		logger = Rails.logger
		
		logger.info "We are beginning!"
		@assignments = Assignment.active
		@assignments.each do |a|
			superstars = Review.where(rating_completed: true, assignment: a).where("completed_at > ?", 1.day.ago).where("accurate_rating + concrete_rating + recognize_rating >= ?", 15).select(:user_id).distinct
			logger.info superstars
			logger.info "Sending emails to superstar reviewers for #{a}!"
			superstars.each do |s|
				logger.info "This is the id: #{s}"
				ReviewMailer.delay.superstar_reviewers_email(s, a.id)
			end
		end
	end
end
