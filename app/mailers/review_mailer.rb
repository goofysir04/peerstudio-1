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
		mail(to: @user.email, subject: 'Hey, can you help me out?')
	end
end
