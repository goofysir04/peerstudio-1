namespace :assignment do 
	task :send_emails_to_volunteers => :environment do
		logger = Rails.logger
		assignments = Assignment.active
		logger.info "Sending emails to people who need it + volunteers"

		#Different database servers on development and production
		if Rails.env.development? 
			random_function = "RANDOM()" #postgresql
		elsif Rails.env.production?
			random_function = "RAND()" #mysql
		else
			logger.info "Choosing created_at because we can't figure out our environment"
			random_function = "created_at"
		end
		
		if !assignments.nil? 
			assignments.each do |assign|
				thirty_min_ans = assign.answers.where(submitted: true).where("submitted_at <= ?", 30.minutes.ago)
				if !thirty_min_ans.empty?
					#here, we find people who still need to give reviews
					have_to_review_still = TriggerAction.where(["trigger = ? and count > ? and ((last_email_time IS NOT ? and last_email_time < ?) or last_email_time IS ?)", "review_required", 0, nil, 12.hours.ago, nil]).order(random_function).limit(4)
					if have_to_review_still.empty? #nil didn't work, so used empty
						#if no one needs to give reviews, we move onto volunteers, aka people who don't need to give any more reviews
						volunteers = TriggerAction.where(["trigger = ? and count > ? and ((last_email_time IS NOT ? and last_email_time < ?) or last_email_time IS ?)", "email_count", 0, nil, 12.hours.ago, nil]).order(random_function).limit(4)
						volunteers.each do |vol| #send email, set last_email_time, decrement "email_count"
							ReviewMailer.delay.need_review_email(vol.user, assign)
							vol.count = vol.count - 1
							vol.last_email_time = Time.now
							vol.save!
						end
					else 
						have_to_review_still.each do |h|
							ReviewMailer.delay.need_review_email(h.user, assign)
							h.last_email_time = Time.now
							h.save!
						end
					end
				end
			end
		end
	end
end
