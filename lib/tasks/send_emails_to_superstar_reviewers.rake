namespace :assignment do 
	task :send_emails_to_superstar_reviewers => :environment do
		logger = Rails.logger
		
		logger.info "Sending emails to superstar reviewers!"
		@assignments = Assignment.active
		@assignments.each do |a|
			superstars = Review.where(rating_completed: true, assignment: a).where("completed_at > ?", 1.day.ago).where("accurate_rating + concrete_rating + recognize_rating >= ?", 15).select(:user_id).distinct 
			superstars.each do |s|
				ReviewMailer.delay.superstar_reviewers_email(s.user_id, a.id)
			end
		end
	end
end

