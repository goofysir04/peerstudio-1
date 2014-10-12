class ReviewMailer < ActionMailer::Base
  default from: "reviews@peerstudio.org"

	def reviewed_email(answer)
		@user = User.find(answer.user_id)
		@reviewed_work = Assignment.find(answer.assignment_id)
		@answer = answer
		mail(to: @user.email, subject: 'Someone reviewed your work!')
	end

	def need_review_email(user, assign, reviewRequests)
		@user = user
		@assignment = assign
		@reviewRequests = reviewRequests
		@numOfReviews = Review.where(["user_id = ? and assignment_id = ? and completed_at IS NOT NULL", user.id, assign.id]).count
		mail(to: @user.email, subject: "A MOOC-mate needs your help on #{@assignment.title}!")
	end
	
	def submit_on_coursera(user_id, assignment_id)
		@user = User.find(user_id)
		@assignment = Assignment.find(assignment_id)
		@answer= Answer.where(assignment: @assignment, user: @user, review_completed: false).order('updated_at desc').first
		if !@answer.nil?
			mail(to: @user.email, subject: "Remember to submit your assignment on Coursera")
		end
	end

	def superstar_reviewers_email(user_id, assignment_id)
		@user = User.find(user_id)
		@assignment = Assignment.find(assignment_id)
		@reviewsWithComments = Review.where(rating_completed: true, assignment: @assignment, user: @user).where("completed_at > ?", 1.day.ago).where("other_rating_comments IS NOT NULL and accurate_rating + concrete_rating + recognize_rating >= ?", 15)
		emailTitle = @user.name + ", you wrote a great review!"
		mail(to: @user.email, subject: emailTitle)
	end

	def unsubmitted_answers_email(answer, assignment)
		@user = User.find(answer.user_id)
		@answer = answer
		@assignment = assignment
		emailTitle = @user.name + ", don't forget to get feedback!"
		mail(to: @user.email, subject: emailTitle)
	end
	
	#begin vineet
	#I dont know how the mail method works, just copying from method above
	def unmailed_reviews(review, assignment)
	  @answer = review.answer
	  @user = @answer.user
	  @assignment = assignment

	  @reviewed_work = @assignment
	  emailTitle = 'Someone reviewed your work!'
	  #mail(to: @user.email, subject: emailTitle)
	  mail(to:@user.email, subject:emailTitle, template_name:"reviewed_email")
	  review.email_sent=true
	  review.save!
	end
	#end vineet

	def unrevised_answers_email(answer, assignment)
		@user = User.find(answer.user_id)
		@answer = answer
		@assignment = assignment
		emailTitle = @user.name + ", use your feedback today!"
		mail(to: @user.email, subject: emailTitle)
	end

	def send_reminder_to_start(user_id, assignment_id)
		@user = User.find(user_id)
		@assignment = Assignment.find(assignment_id)
		mail(to: @user.email, subject: "Do you want feedback on #{@assignment.title}?")
	end

	def send_waitlist_reminder(user_id, assignment_id)
		@user = User.find(user_id)
		@assignment = Assignment.find(assignment_id)
		mail(to: @user.email, subject: "Reminder to get started on #{@assignment.title}")
	end

	def blank_email_notice(answer, user_id, assignment_id)
		@user = User.find(user_id)
		@answer = answer
		@assignment = Assignment.find(assignment_id)
		mail(to: @user.email, subject: "Did you turn in a blank submission?")
	end
end





















