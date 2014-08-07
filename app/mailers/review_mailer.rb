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
		mail(to: @user.email, subject: 'A MOOC-mate needs your help!')
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

	def unrevised_answers_email(answer, assignment)
		@user = User.find(answer.user_id)
		@answer = answer
		@assignment = assignment
		emailTitle = @user.name + ", use your feedback today!"
		mail(to: @user.email, subject: emailTitle)
	end
end
