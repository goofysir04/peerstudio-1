namespace :grading do
	task :enroll_students => :environment do
		logger = Rails.logger
		users = User.all

		#For every submitted answer, find the appropriate course, 
		#and add it to the table

		#Find all the students who submitted an answer.
		logger.info "Adding enrollments for existing students"
		Course.all.each do |c|
			assignments = c.assignments
			submitters = Answer.where("assignment_id in (?)", assignments).select(:user_id).distinct
			submitters.each do |s|
				Enrollment.create(user_id: s.user_id, course_id: c.id)
				logger.info "Created enrollment for user #{s} in course #{c}"
			end
		end
	end
end