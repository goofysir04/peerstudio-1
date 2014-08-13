class ReviewMailer < ActionMailer::Base
  default from: "reviews@peerstudio.org"

	def reviewed_email(answer)
		@user = User.find(answer.user_id)
		@reviewed_work = Assignment.find(answer.assignment_id)
		@answer = answer
		mail(to: @user.email, subject: 'Someone reviewed your work!')
	end

	def need_review_email(user, assign)
		@user = user
		@assignment = assign
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
end
