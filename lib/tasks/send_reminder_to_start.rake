namespace :assignment do 
	task :send_reminder_to_start => :environment do
		logger = Rails.logger
		
		logger.info "Sending emails to people have submitted an earlier assignment, but not the current one!"
		@assignments = Assignment.active
		@assignments.each do |a|
			users_that_havent_started = Enrollment.where(course: a.course)
			users_that_havent_started.each do |enrollment|
				next if enrollment.user.nil?
				if a.answers.where(user: enrollment.user).count > 0
					logger.info "Skipping user: #{enrollment.user.email} because they've already started."
					next
				end
				if enrollment.user.experimental_condition(a.course) == "waitlist"
					logger.info "Sending a wait list reminder"
					ReviewMailer.delay.send_waitlist_reminder(enrollment.user_id, a.id)
				else
					logger.info "Sending an activated reminder"
					ReviewMailer.delay.send_reminder_to_start(enrollment.user_id, a.id)
				end
			end
		end
	end

	task :send_reminder_to_start_those_not_enrolled => :environment do
		logger = Rails.logger
		logger.error "This is a dangerous email."
		logger.info "Sending emails to people haven't enrolled in this course, but used Coursera credentials!"
		a = Assignment.find(9)
		enrollments = Enrollment.where(course: a.course).select("user_id").map { |e| e.user_id }
		users_that_havent_enrolled = User.where(provider: "coursera").where(" id not in (?)", enrollments)
		users_that_havent_enrolled.each do |user|
			next if user.nil?
			if a.answers.where(user: user).count > 0
				logger.info "Skipping user: #{user.email} because they've already started."
				next
			end
			if user.experimental_condition(a.course) == "waitlist"
				logger.info "Sending a wait list reminder"
				ReviewMailer.delay.send_waitlist_reminder(user.id, a.id)
			else
				logger.info "Sending an activated reminder"
				ReviewMailer.delay.send_reminder_to_start(user.id, a.id)
			end
		end
	end
end
