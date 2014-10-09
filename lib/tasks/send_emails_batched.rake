namespace :assignment do 
	task :send_emails_batched => :environment do
		logger = Rails.logger
		
		logger.info "Sending emails to people who have received reviews but haven't been email about them!"
		@assignments = Assignment.active
		@assignments.each do |a|
			#unsubmitted_answers = Answer.where(assignment: a).where(["submitted = ? and updated_at < ? and updated_at > ?", false, Time.now-1.day, Time.now-3.days])
			#unsubmitted_answers.each do |answer|
			#	ReviewMailer.delay.unsubmitted_answers_email(answer, a)
			#begin vineet	
			# sending emails for all those reviews which were updated more than 2 hours ago (randomly chosen) and emails havent been sent already
			unmailed_reviews = Review.where(assignment: a).where(('email_sent IS NULL OR email_sent=?'), false).where(["submitted_at < ?", Time.now-24.hours ])
			puts unmailed_reviews.inspect
			unmailed_reviews.each do |review|
			  ReviewMailer.delay.unmailed_reviews(review, a)
			  review.email_sent=true
			  review.save!
			#end vineet	
			end
		end
	end
end

