namespace :assignment do 
	task :send_emails_to_superstar_reviewers => :environment do
		logger = Rails.logger
		reviews = Review.where(rating_completed: true).where("completed_at > ?", 1.day.ago).where("accurate_rating + concrete_rating + recognize_rating >= ?", 15)
		logger.info "Sending emails to superstar reviewers!"
		
		if !reviews.nil? 
			reviews.each do |r|
				ReviewMailer.delay.superstar_reviewers_email(User.find(r.user_id), r)
			end
		end
	end
end
