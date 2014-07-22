class ReviewMailer < ActionMailer::Base
  default from: "hello@peerstudio.org"

	def reviewed_email(answer)
		@user = User.find(answer.user_id)
		@reviewed_work = Assignment.find(answer.assignment_id)
		mail(to: @user.email, subject: 'Someone reviewed your work!')
	end
end
