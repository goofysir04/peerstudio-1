class ReviewMailer < ActionMailer::Base
  default from: "reviews@peerstudio.org"

	def reviewed_email(answer)
		@user = User.find(answer.user_id)
		@reviewed_work = Assignment.find(answer.assignment_id)
		@answer = answer
		mail(to: @user.email, subject: 'Someone reviewed your work!')
	end

	def need_review_email(user, assignment)
		@user = user
		@assignment = assignment
		mail(to: @user.email, subject: 'Can you help me out?') #edit this later!!!!!
	end
end
