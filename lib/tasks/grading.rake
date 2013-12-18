namespace :grading do
	
	desc "check logger"
	task :push_grades => :environment do
		logger = Rails.logger
		users = User.all

		logger.info "Pushing grades for #{users.count} users"
		users.each	do |user| 
			logger.info "Attempting to push grades for #{user.email} (#{user.cid})"
			Answer.push_grades(user, 0)

			if user.id % 10 == 0
				print "."
				$stdout.flush
			end
		end
	end
end