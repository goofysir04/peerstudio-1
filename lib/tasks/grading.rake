namespace :grading do
	desc "push grades to coursera"
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

	desc "ASSIGNMENT=id; Grade all students for an assignment"
	task :regrade => :environment do 
		assignment_id = ENV['ASSIGNMENT']
		final_draft_name = ENV['FINAL_DRAFT']
		###
		# setup variables
		###
		milestone_credit = 0
		exchange_review_credit = 1
		paired_review_credit = 2 #half for each half of the pair
		final_review_credit = 3
		paired_review_threshold = 1
		final_review_threshold = 1
		

		puts "Regrading Assignment #{assignment_id}"
		assignment = Assignment.find(assignment_id)
		AssignmentGrade.destroy_all(assignment_id: assignment.id)
		Enrollment.where(course: assignment.course).each do |enrollment|
			student = enrollment.user
			#First set participation credit
			assignment.milestones.each do |m|
				answer = Answer.tagged_with(m).where(assignment: assignment, active:true, user: student)
				if answer.count > 0
					# puts "Found answer for student #{student.name} and milestone #{m}"
					# AssignmentGrade.create(user: student, assignment: assignment, grade_type: "Participation credit: #{m}", credit: milestone_credit)
				end
			end

			# transcript = Answer.tagged_with("Transcript Writeup").where(assignment: assignment, active:true, user: student)
			# if(transcript.count > 0)
			# 	AssignmentGrade.create(user: student, assignment: assignment, grade_type: "Completion: Transcript and index", credit: 7)	
			# end

			Review.where(user: student, assignment: assignment, active: true).group(:review_type).count.each do |review_type, review_count|
				if review_type == "exchange"
					AssignmentGrade.create(user: student, assignment: assignment, grade_type: "Participation credit for exchange review", credit: exchange_review_credit, marked_reviews: review_count)
				end

				if review_type == "final" and review_count >= final_review_threshold
					AssignmentGrade.create(user: student, assignment: assignment, grade_type: "Participation credit for final review", credit: final_review_credit, marked_reviews: review_count)
				end
			end

			paired_reviews = Review.where("(user_id = ? or copilot_email= ?) and review_type='paired' and active = ? and assignment_id=?", student.id, student.email, true, assignment.id)
			if paired_reviews.count > paired_review_threshold
				AssignmentGrade.create(user: student, assignment: assignment, grade_type: "Participation credit for paired review", credit: paired_review_credit, marked_reviews: paired_reviews.count)
			end

			##grades for assignment rubrics
			final_answer = Answer.where(user: student, active: true).tagged_with(final_draft_name).first
			if !final_answer.nil?
				final_reviews = Review.where(review_type: "final", active: true, answer_id: final_answer.id)
				assignment.rubric_items.each do |rubric|
					rubric.answer_attributes.each do |answer_attribute|
						marked_count = answer_attribute.feedback_items.where(review_id: final_reviews).select("review_id").distinct.count
						attribute_credit = (if final_reviews.count >= 3 
											 marked_count >= 2 ? answer_attribute.score : 0
											elsif final_reviews.count > 0 and final_reviews.count < 3
											 ((answer_attribute.score * marked_count/final_reviews.count))
											else
												0
											end)

						if answer_attribute.id==70
							attribute_credit = 1
						end
						AssignmentGrade.create(user: student, assignment: assignment, 
							grade_type: "#{rubric.short_title}: #{answer_attribute.description}", 
							credit: attribute_credit, 
							marked_reviews: marked_count, 
							total_reviews: final_reviews.count, 
							rubric_item_id: rubric.id)
					end
				end
			end
		end
	end

	desc "ASSIGNMENT=id; Find assignments with few reviews"
	task :reviews_without_items => :environment do 
		assignment_id = ENV['ASSIGNMENT']
		final_draft_name = ENV['FINAL_DRAFT']
		puts "Finding assignments with problematic reviews"
		answers_without_reviews(assignment_id, final_draft_name)
	end

	def answers_without_reviews(assignment_id, final_draft_name = "Final Draft", reviews_needed = 3)
		assignment_id = ENV['ASSIGNMENT']
		# puts "Inspecting all reviews for Assignment #{assignment_id}"
		assignment = Assignment.find(assignment_id)
		ActionItem.delete_all(assignment: assignment, reason_code: ["TOO_FEW_REVIEWS", "BLANK_REVIEW", "BAD_REVIEW"])

		Enrollment.where(course: assignment.course).each do |enrollment|
			student = enrollment.user
			#First set participation credit
			
			##grades for assignment rubrics
			final_answer = Answer.where(user: student, active: true).tagged_with(final_draft_name).first
			if !final_answer.nil?
				final_reviews = Review.where(review_type: "final", active: true, answer_id: final_answer.id)
				final_reviews.each do |r| 
					review_blank = true
					r.feedback_items.each do |f|
					 if f.answer_attributes.count > 0
					 	review_blank = false
					 end
					end
					if !r.comments.blank?
						review_blank = false
					end

					if review_blank
						ActionItem.create(
							assignment: assignment,
							user: student, 
							reason_code: "BLANK_REVIEW",
							reason: "#{r.user.name} (#{r.user.email}) submitted a blank review. The current grade for submission is #{AssignmentGrade.where(user: student, assignment_id: assignment_id).sum(:credit).round}",
							review: r,
							answer: final_answer
						)
					end

					if r.rating_completed?
						accurate_rating = r.accurate_rating.nil? ? 3.5 : r.accurate_rating #Take the middle value if we don't have a rating
    					concrete_rating = r.concrete_rating.nil? ? 3.5 : r.concrete_rating #Take the middle value if we don't have a rating
    					recognize_rating = r.recognize_rating.nil? ? 3.5 : r.recognize_rating #Take the middle value if we don't have a rating

    					total_rating = accurate_rating + concrete_rating + recognize_rating

    					if total_rating <= 4
    						ActionItem.create(
							assignment: assignment,    							
							user: student, 
							reason_code: "BAD_REVIEW",
							reason: "Review rated poorly.",
							review: r,
							answer: final_answer
							)
    					end
					end
				end

				if final_answer.reviews.where(active: true).count < reviews_needed
					ActionItem.create(
							assignment: assignment,
							user: student, 
							reason_code: "TOO_FEW_REVIEWS",
							reason: "Submission has only #{final_reviews.count} reviews, we need #{reviews_needed}. The current grade for submission is #{AssignmentGrade.where(user: student, assignment_id: assignment_id).sum(:credit).round}",
							answer: final_answer,
							priority: 3 + (reviews_needed - final_answer.reviews.where(active: true).count)
						)
				end
			end
		end
	end
end