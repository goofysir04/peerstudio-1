namespace :grading do
	task :set_reviews_to_active => :environment do
		logger = Rails.logger
		users = User.all

		#For every submitted answer, find the appropriate course, 
		#and add it to the table

		#Find all the students who submitted an answer.
		logger.info "Activating existing reviews"
		Review.all.each do |r|
			if r.created_at == r.updated_at
				r.active = false
				r.save
			end
		end
	end
end